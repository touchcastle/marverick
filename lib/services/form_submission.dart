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

import 'dart:async';
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
      Log.add(
          '${form.id} missing required fields (${form.percentFilled()}% filled)');
      onResult('Please fill in all required fields before submitting.',
          ErrorType.missingRequired);
      return;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      onResult(
          'No internet connection — saved to Pending. You can submit it once you\'re back online.',
          ErrorType.noInternet);
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
        onResult(validationError, ErrorType.validate);
        return;
      }

      // Generate PDF. Only forward gen's *errors* (e.g. a field that failed to
      // render) — not its success signal, which would otherwise be treated as
      // the whole submission succeeding before the upload/post even happen.
      Log.add('${form.id} start gen pdf');
      final String pdfFileName = PdfNameResolver.resolve(form, submitDate);
      final List<int> pdfBytes = await _pdf.gen(form, (msg, type) {
        if (type != ErrorType.success) onResult(msg, type);
      });

      // Write to temp file
      final dir = await path_provider.getApplicationSupportDirectory();
      final tempFile = File('${dir.path}/$pdfFileName');
      await tempFile.writeAsBytes(pdfBytes, flush: true);
      Log.add('${form.id} pdf written to ${tempFile.path}');

      // Upload to Firebase Storage (bounded — a real hang is caught here and
      // reported, rather than the whole submit being raced by an outer timer).
      Log.add('${form.id} uploading pdf');
      final storagePath = '${form.type.folderName}/$pdfFileName';
      final snapshot = await _storage
          .ref()
          .child(storagePath)
          .putFile(tempFile)
          .timeout(kUploadTimeout);

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
        Log.add('${form.id} no sheet URL configured for ${form.type}');
        onResult(
            'Couldn\'t submit — this form isn\'t set up for submission yet. Please contact support.',
            ErrorType.other);
        return;
      }

      final response = await http
          .post(Uri.parse(sheetUrl), body: form.formMap())
          .timeout(kSheetTimeout);

      Log.add('${form.id} sheet response: ${response.statusCode}');

      if (response.statusCode == 302) {
        // Apps Script redirects on success — follow the redirect.
        final redirectUrl = response.headers['location'];
        if (redirectUrl == null) {
          Log.add('${form.id} 302 with no location header');
          onResult('Couldn\'t confirm submission — please try again.',
              ErrorType.other);
          return;
        }
        await http.get(Uri.parse(redirectUrl)).timeout(kSheetTimeout);
        form.submitDateTime = submitDate;
        Log.add('${form.id} sheet submission success');
        onResult(kStatusSuccess, ErrorType.success);
      } else {
        Log.add('${form.id} sheet error code: ${response.statusCode}');
        onResult('Couldn\'t submit — the server didn\'t accept the form. Please try again.',
            ErrorType.other);
      }
    } on TimeoutException catch (e) {
      Log.add('${form.id} submit timeout: $e');
      onResult(
          'Submission is taking too long — please check your connection and try again.',
          ErrorType.other);
    } catch (e) {
      Log.add('${form.id} error: $e');
      onResult('Couldn\'t submit — please try again.', ErrorType.other);
    }
  }
}
