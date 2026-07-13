// lib/services/form_submission.dart
//
// Handles the full form submission flow:
//   1. Validate form completeness
//   2. Generate PDF bytes
//   3. Write PDF to temp file
//   4. Upload PDF to Firebase Storage
//   5. POST form data to Google Sheets via Apps Script
//
// Extracted from form_service.dart. Uses sequential await instead of
// mixed async/await + .then() nesting.

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:marverick/models/form.dart' as f;
import 'package:marverick/services/authen.dart';
import 'package:marverick/services/log.dart';
import 'package:marverick/services/pdf.dart';
import 'package:marverick/services/pdf_name_resolver.dart';
import 'package:marverick/services/form_type_config.dart';
import 'package:marverick/utils/constants.dart';

class FormSubmission {
  final Pdf _pdf;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FormSubmission({required Pdf pdf}) : _pdf = pdf;

  /// Submits [form] to Firebase Storage + Google Sheets.
  ///
  /// Calls [onResult] with a status message and [ErrorType] on every outcome.
  /// Calls [onPending] when there is no internet connection.
  Future<void> submit({
    required f.Form form,
    required void Function(String message, ErrorType type) onResult,
    required void Function() onPending,
  }) async {
    // Sample mode: skip real submission.
    if (Authen.isSample) {
      onResult(kStatusSuccess, ErrorType.success);
      return;
    }

    if (form.percentFilled() < 100 && !Authen.isAdmin()) {
      onResult('ERROR: Please fill all required fields', ErrorType.missingRequired);
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      onResult('No internet connection: Form moved to pending', ErrorType.noInternet);
      onPending();
      return;
    }

    final submitDate = DateTime.now();
    Log.add('${form.id} start submit');

    try {
      // Validate
      final validationError = form.validate();
      if (validationError.isNotEmpty) {
        Log.add('${form.id} validation fault: $validationError');
        onResult('ERROR: $validationError', ErrorType.validate);
        return;
      }

      // Generate PDF
      Log.add('${form.id} start gen pdf');
      final String pdfFileName = PdfNameResolver.resolve(form, submitDate);
      final List<int> pdfBytes = await _pdf.gen(form, (msg, type) {
        onResult(msg, type);
      });

      // Write to temp file
      final dir = await path_provider.getApplicationSupportDirectory();
      final tempFile = File('${dir.path}/$pdfFileName');
      await tempFile.writeAsBytes(pdfBytes, flush: true);
      Log.add('${form.id} pdf written to ${tempFile.path}');

      // Upload to Firebase Storage
      Log.add('${form.id} uploading pdf');
      final storagePath = '${form.type.folderName}/$pdfFileName';
      final snapshot = await _storage.ref().child(storagePath).putFile(tempFile);

      if (snapshot.state == TaskState.success) {
        form.pdfUrl = await snapshot.ref.getDownloadURL();
        Log.add('${form.id} pdf uploaded to ${form.pdfUrl}');
      } else {
        form.pdfUrl = 'error';
        Log.add('${form.id} pdf upload failed: ${snapshot.state}');
      }

      // Submit to Google Sheets
      Log.add('${form.id} posting to google sheet');
      final sheetUrl = form.type.sheetUrl;
      if (sheetUrl.isEmpty) {
        onResult('ERROR: No sheet URL configured for this form type', ErrorType.other);
        return;
      }

      final response = await http.post(
        Uri.parse(sheetUrl),
        body: form.formMap(),
      );

      Log.add('${form.id} sheet response: ${response.statusCode}');

      if (response.statusCode == 302) {
        // Apps Script redirects on success — follow the redirect.
        final redirectUrl = response.headers['location'];
        if (redirectUrl == null) {
          onResult('ERROR: Redirect URL missing', ErrorType.other);
          return;
        }
        await http.get(Uri.parse(redirectUrl));
        form.submitDateTime = submitDate;
        Log.add('${form.id} sheet submission success');
        onResult(kStatusSuccess, ErrorType.success);
      } else {
        onResult('Sheet error code: ${response.statusCode}', ErrorType.other);
      }
    } catch (e) {
      Log.add('${form.id} error: $e');
      onResult('ERROR: $e', ErrorType.other);
    }
  }
}
