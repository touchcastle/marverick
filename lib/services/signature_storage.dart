// lib/services/signature_storage.dart
//
// Handles saving and loading signature image bytes to/from the device filesystem.
// Extracted from form_service.dart.

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class SignatureStorage {
  /// Returns the full file path for a signature identified by [name].
  static Future<String> _filePath(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$name';
  }

  /// Saves [bytes] to device storage under [name].
  static Future<void> save(String name, Uint8List bytes) async {
    final file = File(await _filePath(name));
    await file.writeAsBytes(bytes);
  }

  /// Reads and returns the bytes stored under [name].
  /// Throws a [FileSystemException] if the file does not exist.
  static Future<Uint8List> read(String name) async {
    final file = File(await _filePath(name));
    return file.readAsBytes();
  }

  /// Returns true if a signature file exists for [name].
  static Future<bool> exists(String name) async {
    final file = File(await _filePath(name));
    return file.exists();
  }
}
