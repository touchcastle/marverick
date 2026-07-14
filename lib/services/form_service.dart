import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/models/field.dart';
import 'package:marverick/services/pdf.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/services/database.dart';
import 'package:marverick/services/firestore_sync.dart';
import 'package:marverick/services/form_submission.dart';
import 'package:marverick/services/log.dart';
import 'package:marverick/services/signature_storage.dart';
import 'package:marverick/ui/views/input.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/utils/utils.dart';

class FormService extends ChangeNotifier {
  Authen authen;
  Pdf pdf;
  late final FormSubmission _submission;
  final FirestoreSync _sync = FirestoreSync();

  List<f.Form> forms = [];

  FormService({required this.authen, required this.pdf}) {
    _submission = FormSubmission(pdf: pdf);
  }

  static var uuid = Uuid();

  int pendingCount = 0;
  int draftCount = 0;

  void newForm(BuildContext c, f.Form form) {
    // forms.add(form);
    forms.insert(0, form);
    Log.add("New form ${form.type}");
    countPending();
    notifyListeners();
    Navigator.of(c).push(PageRouteBuilder(
        settings: RouteSettings(name: kInputPageName),
        pageBuilder: (_, __, ___) => InputScreen(
              form: forms[0],
              // form: forms[forms.length - 1],
            )));
  }

  // void duplicateForm(f.Form origin) {
  //   f.Form appending = origin.copyWith(
  //     createDateTime: DateTime.now(),
  //     createBy: Authen.user != null ? Authen.user.email : '',
  //     id: uuid.v1(),
  //   );
  //   forms.insert(0, appending);
  //   countPending();
  //   notifyListeners();
  // }

  void moveToComplted(f.Form form) {
    int _i = forms.indexWhere((e) => e.id == form.id);
    forms[_i].status = f.FormStatus.completed;
    save(form);
    // Sync temporarily disabled.
    // _sync.pushForm(form, immediate: true, onSettled: (ok) => _markSynced(form, ok));
    Log.clear();
    countPending();
    notifyListeners();
  }

  void moveToPending(f.Form form) {
    try {
      int _i = forms.indexWhere((e) => e.id == form.id);
      forms[_i].status = f.FormStatus.pending;
      Log.add("Form ${form.id} moved to pending");
      save(form);
      // Sync temporarily disabled.
      // _sync.pushForm(form, immediate: true, onSettled: (ok) => _markSynced(form, ok));
      countPending();
      notifyListeners();
    } catch (e) {}
  }

  /// Reflects [form]'s actual sync outcome and refreshes the UI (the file
  /// list's cloud icon watches `FormService`, not individual `Form`s).
  void _markSynced(f.Form form, bool synced) {
    form.synced = synced;
    notifyListeners();
  }

  /// Identifies the signed-in account for scoping local reads/sync so a
  /// shared device never shows or syncs another account's forms.
  String? get _currentAccountKey =>
      Authen.isSample ? kSampleMail : Authen.user?.email;

  void countPending() {
    pendingCount =
        forms.where((c) => c.status == f.FormStatus.pending).toList().length;
    draftCount =
        forms.where((c) => c.status == f.FormStatus.working).toList().length;
  }

  /// Submits [form]: saves it locally, generates its PDF, uploads to Firebase
  /// Storage, and posts its data to the Google Sheet for its type.
  Future submitForm(
      f.Form form, void Function(String, ErrorType) callback) async {
    Log.add("${form.id} start submit");
    if (!Authen.isSample) {
      await save(form);
    }
    await _submission.submit(
      form: form,
      onResult: (message, type) {
        if (type == ErrorType.success && !Authen.isSample) {
          moveToComplted(form);
        }
        callback(message, type);
      },
      onPending: () => moveToPending(form),
    );
  }

  ///===========================================================================
  ///DATABASE
  ///===========================================================================
  Future loadFromDatabase() async {
    // Local data loads first and is what the app runs on — this must never
    // wait on the network, since the whole point is to keep working (e.g.
    // in airplane mode) with local storage as the source of truth. Scoped to
    // the signed-in account so a shared device never shows another
    // account's forms.
    forms = await databaseService.dbQuery(createBy: _currentAccountKey);
    await _loadSignatures(forms);

    // Cloud sync happens strictly in the background: it can take a while or
    // fail entirely offline, and must never block startup or hold up the
    // forms list the user is already looking at.
    // Sync temporarily disabled.
    // _syncInBackground();
  }

  Future<void> _syncInBackground() async {
    final createBy = _currentAccountKey;
    if (createBy == null) return;
    final results = await _sync.reconcile(createBy);

    final refreshed = await databaseService.dbQuery(createBy: createBy);
    if (refreshed.length != forms.length) {
      forms = refreshed;
      await _loadSignatures(forms);
      countPending();
    }
    // Reflect reconcile's findings on the live, UI-bound form instances.
    // Forms missing from `results` (Firestore unreachable) keep whatever
    // sync status they already had.
    for (final form in forms) {
      final result = results[form.id];
      if (result != null) form.synced = result;
    }
    notifyListeners();
  }

  /// Triggers an immediate reconcile with Firestore instead of waiting for
  /// the background pass, for the manual "sync now" button. Returns a short
  /// status message for the UI to show.
  Future<String> manualSync() async {
    if (Authen.isSample) return 'Sample mode does not sync';
    final createBy = _currentAccountKey;
    if (createBy == null) return 'Not signed in';

    print('[FormService] Manual sync requested for $createBy');
    final results = await _sync.reconcile(createBy);

    forms = await databaseService.dbQuery(createBy: createBy);
    await _loadSignatures(forms);
    countPending();
    for (final form in forms) {
      final result = results[form.id];
      if (result != null) form.synced = result;
    }
    notifyListeners();

    if (results.isEmpty) {
      print('[FormService] Manual sync: nothing to reconcile');
      return 'Nothing to sync';
    }
    final failed = results.values.where((ok) => !ok).length;
    final message = failed == 0
        ? 'Synced ${results.length} form${results.length == 1 ? '' : 's'}'
        : '$failed of ${results.length} form${results.length == 1 ? '' : 's'} failed to sync';
    print('[FormService] Manual sync result: $message');
    return message;
  }

  Future<void> _loadSignatures(List<f.Form> list) async {
    for (int i = 0; i < list.length; i++) {
      for (int f = 0; f < list[i].fields.length; f++) {
        if (list[i].fields[f].type == FieldType.signature) {
          try {
            list[i].fields[f].signature = await SignatureStorage.read(
                '${list[i].id}${list[i].fields[f].name}');
          } catch (e) {
            print('read signature error: $e');
          }
        }
      }
    }
  }

  /// TODO: New form (3) add exclusion of new form for test
  /// TODO: New form (5) remove exclusion
  Future save(f.Form form, {bool showLoad = false}) async {
    // if (form.type != f.FormType.rt4 || form.type != f.FormType.ppc8) {
      print(form.dbTable);
      if (!Authen.isSample) {
        showLoad ? Utils.showInProgress(true) : null;
        try {
          // Claims a legacy/orphaned form (created before create_by was
          // populated, e.g. an old login race) for the current account, so
          // it converges to properly attributed instead of staying
          // unattributed indefinitely.
          if (form.createBy.isEmpty && _currentAccountKey != null) {
            form.createBy = _currentAccountKey!;
          }
          final data = form.formMap();
          if (data.isNotEmpty) {
            data['updated_at'] = DateTime.now().toIso8601String();
            // A local change just landed that Firestore hasn't seen yet —
            // reflect that immediately; pushForm's onSettled flips it back
            // once the (possibly debounced) push actually succeeds.
            form.synced = false;
          }
          await databaseService.dbInsert(data, form.dbTable);

          ///Save signature
          ///Only persists a signature that was already explicitly confirmed
          ///via the signature pad's own save button (field.signature) —
          ///must NOT re-derive from the live drawing controller here, since
          ///the controller keeps whatever is currently drawn even if never
          ///confirmed. Re-deriving on every autosave (e.g. the one that
          ///fires when backing out of the input screen) would silently
          ///commit an unconfirmed re-signing over the previously saved one.
          for (int i = 0; i < form.fields.length; i++) {
            if (form.fields[i].type == FieldType.signature) {
              if (form.fields[i].signature != null) {
                await SignatureStorage.save('${form.id}${form.fields[i].name}',
                    form.fields[i].signature!);
              }
            }
          }
          // Sync temporarily disabled.
          // await _sync.pushForm(form, onSettled: (ok) => _markSynced(form, ok));
        } catch (e) {
          print(e);
        }
        showLoad ? Utils.showInProgress(false) : null;
        notifyListeners();
      }
    // }
  }

  ///TODO: New form (9): Add new form delete db
  void delete(f.Form form, void Function(String) callback) async {
    try {
      forms.removeWhere((e) => e.id == form.id);
      await databaseService.dbDelete(form, form.dbTable);
      // Not awaited: the local delete is what the user is waiting on, and
      // Firestore deletes don't resolve until the server acknowledges them
      // — that must never hold up the local delete when offline.
      // Sync temporarily disabled.
      // _sync.deleteForm(form.id);
      notifyListeners();
      callback(kStatusSuccess);
    } catch (e) {
      callback('$e');
    }
  }

}
