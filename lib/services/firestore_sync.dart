// lib/services/firestore_sync.dart
//
// Syncs form data to Cloud Firestore so a signed-in user's in-progress and
// completed forms follow them across devices. The local SQLite database
// (see database.dart) remains the source of truth for reads/writes within
// the app — this is purely a push/pull bridge on top of it.
//
// Conflict rule: whichever side (local vs cloud) was modified most recently
// wins, compared via each side's `updated_at`. Data is scoped per account —
// Firestore documents live under users/{uid}/forms (enforced by security
// rules), and the local side is scoped by the `create_by` column the caller
// passes into `reconcile()`.

import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:marverick/models/field.dart';
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/services/authen.dart';
import 'package:marverick/services/database.dart';
import 'package:marverick/services/form_type_config.dart';
import 'package:marverick/services/log.dart';
import 'package:marverick/services/signature_storage.dart';

class FirestoreSync {
  static const _debounceDuration = Duration(seconds: 4);

  // Firestore's write/read futures don't resolve until the server
  // acknowledges them — with no network at all (e.g. airplane mode) they
  // would otherwise hang indefinitely. Every network call here is bounded so
  // sync is always best-effort and never blocks or hangs the app.
  static const _networkTimeout = Duration(seconds: 8);

  final Map<String, Timer> _debounceTimers = {};
  final Map<String, Uint8List> _lastUploadedSignatures = {};

  bool get _enabled => !Authen.isSample && Authen.user != null;

  CollectionReference<Map<String, dynamic>> _forms(String uid) =>
      FirebaseFirestore.instance.collection('users/$uid/forms');

  DateTime _parseTime(String? value) =>
      value == null ? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.parse(value);

  /// Pushes [form] to Firestore. Debounced per form id unless [immediate] is
  /// true, since `FormService.save()` fires on nearly every field edit via
  /// the input screen's autosave — pushing on every keystroke would be
  /// wasteful and costly. [onSettled] fires with the actual push result once
  /// it happens — for the debounced path that's later, when the timer fires,
  /// so callers that need to reflect "synced" state in the UI should use it
  /// rather than this method's own return value. The return value only
  /// reflects the debounced/no-op paths (always `true`, since those don't
  /// wait on the network) or the immediate path's real result.
  Future<bool> pushForm(f.Form form,
      {bool immediate = false, void Function(bool success)? onSettled}) async {
    if (!_enabled) return true;
    final data = form.formMap();
    // Dormant types (ppc, rt5, rt6, loe, sample) have no live mapping.
    if (data.isEmpty) return true;

    _debounceTimers[form.id]?.cancel();
    if (!immediate) {
      print('[FirestoreSync] push scheduled for ${form.id} (${form.type}), '
          'debouncing ${_debounceDuration.inSeconds}s');
      _debounceTimers[form.id] = Timer(_debounceDuration, () async {
        final ok = await _push(form, data);
        onSettled?.call(ok);
      });
      return true;
    }
    final ok = await _push(form, data);
    onSettled?.call(ok);
    return ok;
  }

  Future<bool> _push(f.Form form, Map<String, dynamic> data) async {
    print('[FirestoreSync] pushing ${form.id} (${form.type})...');
    try {
      final uid = Authen.user.uid as String;
      final signatures = await _uploadChangedSignatures(form, uid);
      if (signatures.isNotEmpty) data['_signatures'] = signatures;
      data['updated_at'] = DateTime.now().toIso8601String();
      await _forms(uid)
          .doc(form.id)
          .set(data, SetOptions(merge: true))
          .timeout(_networkTimeout);
      print('[FirestoreSync] push SUCCEEDED for ${form.id}');
      return true;
    } catch (e) {
      print('[FirestoreSync] push FAILED for ${form.id}: $e');
      Log.add('Firestore push failed for ${form.id}: $e');
      return false;
    }
  }

  /// Uploads any signature whose bytes changed since the last upload and
  /// returns a map of field name -> download URL for the ones just uploaded
  /// or already known. Skips re-uploading unchanged signatures.
  Future<Map<String, String>> _uploadChangedSignatures(
      f.Form form, String uid) async {
    final result = <String, String>{};
    for (final field in form.fields) {
      if (field.type != FieldType.signature) continue;
      final bytes = field.signature;
      if (bytes == null || bytes.isEmpty) continue;

      final cacheKey = '${form.id}_${field.name}';
      final cached = _lastUploadedSignatures[cacheKey];
      if (cached != null && _bytesEqual(cached, bytes)) continue;

      final ref = FirebaseStorage.instance
          .ref()
          .child('signatures/$uid/${form.id}_${field.name}.png');
      await ref
          .putData(bytes, SettableMetadata(contentType: 'image/png'))
          .timeout(_networkTimeout);
      result[field.name] =
          await ref.getDownloadURL().timeout(_networkTimeout);
      _lastUploadedSignatures[cacheKey] = bytes;
    }
    return result;
  }

  bool _bytesEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Deletes [formId]'s Firestore document. Not debounced — deletions must
  /// be reliable rather than eventually-consistent.
  Future<void> deleteForm(String formId) async {
    if (!_enabled) return;
    print('[FirestoreSync] deleting $formId...');
    try {
      final uid = Authen.user.uid as String;
      _debounceTimers.remove(formId)?.cancel();
      await _forms(uid).doc(formId).delete().timeout(_networkTimeout);
      print('[FirestoreSync] delete SUCCEEDED for $formId');
    } catch (e) {
      print('[FirestoreSync] delete FAILED for $formId: $e');
      Log.add('Firestore delete failed for $formId: $e');
    }
  }

  /// Reconciles the current account's forms between the local database and
  /// Firestore: a form that only exists on one side gets copied to the
  /// other, and a form that exists on both sides is resolved by whichever
  /// side's `updated_at` is more recent. [createBy] scopes the local side to
  /// a single account (see `DatabaseService.dbQuery`).
  ///
  /// Returns a form id -> synced map so the caller can reflect accurate
  /// "synced with cloud" status in the UI for every form it looked at. A
  /// form is missing from the map only if reconcile couldn't reach Firestore
  /// at all (e.g. offline) — callers should leave those forms' status as-is.
  Future<Map<String, bool>> reconcile(String createBy) async {
    if (!_enabled) {
      print('[FirestoreSync] reconcile skipped (sample mode or signed out)');
      return {};
    }
    print('[FirestoreSync] reconcile starting for $createBy...');
    final results = <String, bool>{};
    try {
      final uid = Authen.user.uid as String;
      final localForms = await databaseService.dbQuery(createBy: createBy);
      final localById = {for (final form in localForms) form.id: form};
      final snapshot = await _forms(uid).get().timeout(_networkTimeout);
      final cloudById = {for (final doc in snapshot.docs) doc.id: doc};
      print('[FirestoreSync] reconcile: ${localById.length} local, '
          '${cloudById.length} cloud form(s) for $createBy');

      for (final id in {...localById.keys, ...cloudById.keys}) {
        final local = localById[id];
        final cloudDoc = cloudById[id];
        try {
          if (local != null && cloudDoc == null) {
            print('[FirestoreSync] $id: local only -> push');
            results[id] = await pushForm(local, immediate: true);
          } else if (local == null && cloudDoc != null) {
            print('[FirestoreSync] $id: cloud only -> pull');
            results[id] = await _pullDoc(cloudDoc);
          } else if (local != null && cloudDoc != null) {
            final localUpdatedAt =
                await databaseService.getUpdatedAt(local.dbTable, id);
            final cloudUpdatedAt = cloudDoc.data()['updated_at'] as String?;
            final localTime = _parseTime(localUpdatedAt);
            final cloudTime = _parseTime(cloudUpdatedAt);
            if (cloudTime.isAfter(localTime)) {
              print('[FirestoreSync] $id: cloud newer ($cloudUpdatedAt > '
                  '$localUpdatedAt) -> pull');
              results[id] = await _pullDoc(cloudDoc);
            } else if (localTime.isAfter(cloudTime)) {
              print('[FirestoreSync] $id: local newer ($localUpdatedAt > '
                  '$cloudUpdatedAt) -> push');
              results[id] = await pushForm(local, immediate: true);
            } else {
              print('[FirestoreSync] $id: already in sync');
              results[id] = true;
            }
          }
        } catch (e) {
          // Isolate failures per form so one bad doc doesn't abort
          // reconciling the rest of the account's forms.
          print('[FirestoreSync] $id: reconcile FAILED: $e');
          Log.add('Firestore reconcile failed for $id: $e');
          results[id] = false;
        }
      }
    } catch (e) {
      print('[FirestoreSync] reconcile FAILED: $e');
      Log.add('Firestore reconcile failed: $e');
    }
    final failed = results.values.where((ok) => !ok).length;
    print('[FirestoreSync] reconcile finished for $createBy: '
        '${results.length} form(s) processed, $failed failed');
    return results;
  }

  Future<bool> _pullDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = Map<String, dynamic>.from(doc.data());
    final signatures =
        Map<String, dynamic>.from(data.remove('_signatures') ?? {});
    final type =
        f.FormType.values.firstWhere((t) => t.toString() == data['type']);
    await databaseService.dbInsert(data, type.dbTable);

    for (final entry in signatures.entries) {
      final bytes = await FirebaseStorage.instance
          .refFromURL(entry.value as String)
          .getData()
          .timeout(_networkTimeout);
      if (bytes != null) {
        await SignatureStorage.save('${doc.id}${entry.key}', bytes);
      }
    }
    return true;
  }
}
