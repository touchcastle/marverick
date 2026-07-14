// Code-level PPC8 submission test: builds a PPC8 form entirely in Dart
// (pilot_name = "claude test", every other required field auto-filled),
// runs it through the real Pdf.gen() and a real Firebase Storage upload —
// deliberately does NOT post to the production Google Sheet. Uploads land
// under test-submissions/ppc8/ so they're clearly separated from real
// pilot submissions.

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';

import 'package:marverick/models/field.dart';
import 'package:marverick/services/forms/ppc8_form.dart';
import 'package:marverick/services/pdf.dart';
import 'package:marverick/utils/constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PPC8: real PDF gen + Storage upload, no sheet post',
      (tester) async {
    await Firebase.initializeApp();

    final form = Ppc8Form.init();
    final random = Random();

    for (final field in form.fields) {
      // Skip companion/derived fields — not directly user-editable, and
      // already carry a valid default value (e.g. checkbox mirror fields,
      // duplicate-signature-name fields).
      if (!field.input || field.duplicateFrom != null) continue;

      if (field.name == 'pilot_name') {
        field.stringValue = 'claude test';
        continue;
      }

      switch (field.type) {
        case FieldType.string:
          field.stringValue = 'Test ${field.name}';
          break;
        case FieldType.date:
          field.dateTimeValue = DateTime.now();
          field.stringValue =
              DateFormat(form.dateFormat).format(DateTime.now());
          break;
        case FieldType.radio:
        case FieldType.dropdown:
          if (field.listValue.isNotEmpty) {
            final i = random.nextInt(field.listValue.length);
            field.intValue = i;
            field.stringValue = field.listValue[i];
          }
          break;
        case FieldType.checkbox:
          if (field.checkBoxValue.isNotEmpty) {
            final chosen = random.nextInt(field.checkBoxValue.length);
            field.checkBoxValue = List.generate(
                field.checkBoxValue.length, (i) => i == chosen);
          }
          break;
        case FieldType.int:
          field.intValue = random.nextInt(5) + 1;
          field.stringValue = field.intValue.toString();
          break;
        case FieldType.bool:
          field.boolValue = true;
          break;
        case FieldType.signature:
          field.signature = await _testSignaturePng();
          break;
        case FieldType.image:
          break;
      }
    }

    // ignore: avoid_print
    print('[Ppc8Test] allRequired=${form.allRequired()} '
        'filledRequired=${form.filledRequired()} '
        'percent=${form.percentFilled()}');
    expect(form.percentFilled(), 100.0,
        reason: 'All mandatory fields must be filled before PDF generation');

    final pdf = Pdf();
    final pdfBytes = await pdf.gen(form, (String msg, ErrorType type) {
      // ignore: avoid_print
      print('[Ppc8Test] pdf.gen callback: $msg ($type)');
    });
    expect(pdfBytes, isNotEmpty);
    // ignore: avoid_print
    print('[Ppc8Test] Generated PDF: ${pdfBytes.length} bytes');

    final fileName = 'claude_test_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final ref =
        FirebaseStorage.instance.ref().child('test-submissions/ppc8/$fileName');
    await ref.putData(Uint8List.fromList(pdfBytes));
    final url = await ref.getDownloadURL();
    // ignore: avoid_print
    print('[Ppc8Test] Uploaded to Firebase Storage: $url');

    expect(url, isNotEmpty);
  });
}

Future<Uint8List> _testSignaturePng() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;
  canvas.drawLine(const Offset(5, 5), const Offset(95, 45), paint);
  canvas.drawLine(const Offset(95, 5), const Offset(5, 45), paint);
  final picture = recorder.endRecording();
  final img = await picture.toImage(100, 50);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
