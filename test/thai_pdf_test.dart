// Reproduces the "character is not supported by the font" crash: fills a form
// field with Thai text (incl. ม / U+0E21, the char in the reported error 3617)
// and generates the PDF. With Sarabun embedded, gen() must NOT hit the
// per-field error path and must return a non-empty PDF.
import 'package:flutter_test/flutter_test.dart';
import 'package:marverick/services/pdf.dart';
import 'package:marverick/services/forms/ppc8_form.dart';
import 'package:marverick/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PPC8 with Thai field text renders without font error', () async {
    final form = Ppc8Form.init();

    // Thai text containing ม (U+0E21 = 3617) plus mixed Latin.
    form.fields.firstWhere((f) => f.name == 'pilot_name').stringValue =
        'สมชาย ใจดี MAVERICK';
    form.fields.firstWhere((f) => f.name == 'general_comment').stringValue =
        'ทดสอบภาษาไทย ผ่านการตรวจ (comment ม)';

    final messages = <String>[];
    final bytes = await Pdf().gen(form, (String msg, ErrorType type) {
      messages.add(msg);
    });

    final fontErrors =
        messages.where((m) => m.contains('error when writing')).toList();

    print('callback messages: $messages');
    print('pdf byte length: ${bytes.length}');

    expect(fontErrors, isEmpty,
        reason: 'a field failed to render — font error path was hit');
    expect(bytes.length, greaterThan(1000), reason: 'PDF should be produced');
  });
}
