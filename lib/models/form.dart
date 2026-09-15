import 'package:flutter/cupertino.dart';
import 'package:marverick/models/field.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/services/log.dart';
import 'package:intl/intl.dart';

/// ============================================================================
/// HOW TO ADD A NEW FORM  (current process — search "New form: step N")
/// ============================================================================
/// Most of the old boilerplate is now automated (submission mapping + table
/// creation), so a new form is mainly: define its fields, register it, and
/// show it in the menu. Steps, in order:
///
///  1. models/form.dart          — add the type to the [FormType] enum (below).
///  2. services/forms/<x>_form.dart — new file with `static Form init()`
///                                 defining the fields + `filePath`. No toMap()
///                                 needed; the generic mapper handles it.
///  3. assets/forms/<x>.pdf       — add the template PDF and point init()'s
///                                 `filePath` at it (also list it under
///                                 `flutter: assets:` if it's a new folder).
///  4. utils/constants.dart       — add `k<X>Table` and `k<X>SheetUrl`, and add
///                                 `k<X>Table` to `kDbTableList`.
///  5. services/form_type_config.dart — add one `_formConfig` entry (name,
///                                 folder fn, url, dbTable).
///  6. models/form.dart          — add the type to the `defaultMap()` group in
///                                 [formMap] (see "New form: step 6").
///  7. services/database.dart    — table create + migration:
///                                 (a) add `createFormTable(db, k<X>Table,
///                                     <X>Form.init())` to `onCreateTable`;
///                                 (b) add the same call in a new
///                                     `oldVersion == N` block of
///                                     `onUpdateTable` AND bump the `version:`
///                                     in `openDB()`.
///  8. services/database.dart    — add the load branch in `dbQuery` (see
///                                 "New form: step 8").
///  9. services/pdf_name_resolver.dart — add the type to a filename group only
///                                 if it needs a custom PDF name (else it uses
///                                 the default `<id>.pdf`).
/// 10. ui/views/main_menu.dart   — add a `SpeedDialChild` that calls
///                                 `newForm(context, <X>Form.init())`.
/// 11. models/form.dart          — (optional) add cross-field checks in
///                                 [validate] if the form needs them.
/// 12. (external) Create the Google Sheet + deploy its Apps Script, then put
///     the /exec URL in `k<X>SheetUrl`.
///
/// Note: save & delete need NO per-form work — they route through
/// `form.dbTable` (from form_type_config) generically.
/// ============================================================================
///
/// Only the forms offered in the main menu (plus [sample] for the demo account)
/// remain. Retired form types and their per-form files were removed; their
/// SQLite tables are intentionally kept in database.dart for upgrade safety.
enum FormType {
  // todo: New form step 1 — add the new type to this enum.
  // todo: New form step 2 — create lib/services/forms/<x>_form.dart with a
  //       `static Form init()` defining the fields (+ filePath). No toMap().
  // todo: New form step 3 — add the template PDF to assets/forms/<x>.pdf and
  //       point init()'s filePath at it (list a new folder under flutter:assets).
  sample,
  lineCheck5,
  ppc6,
  ppc8,
  stdloft, //Standard LOFT (a320/b737)
  rt3,
  rt4,
  lineTrain,
  fcss, //Flight Crew Simulator Screening
  diff, //B737 Difference Training
}

enum FormStatus { working, completed, pending }

class Form extends ChangeNotifier {
  ///Auto generate UUID
  String id;
  FormStatus status;
  FormType type;
  String formName;
  DateTime createDateTime;
  DateTime? submitDateTime;
  String createBy;
  List<Field> fields;
  String filePath;
  double fontSize;
  String dbTable;
  String dateFormat;
  bool ruler;

  /// Section label as in PDF
  List<String> sectionLabel;

  /// Grading section label as in PDF
  List<String>? gradeSectionLabel;

  /// for display form list in main screen
  String formLabel;
  String? formLabelInfoField1;
  String? formLabelInfoField2;
  String? pdfUrl;

  /// Whether the last local save of this form has been confirmed synced to
  /// Firestore. In-memory only — not persisted, not part of [formMap]; it's
  /// recomputed each session by `FirestoreSync` and kept live by
  /// `FormService` as saves/pushes happen.
  bool synced = true;

  Form({
    this.status = FormStatus.working,
    required this.type,
    required this.formName,
    required this.createDateTime,
    required this.createBy,
    required this.fields,
    required this.id,
    required this.filePath,
    required this.fontSize,
    required this.formLabel,
    required this.sectionLabel,
    this.gradeSectionLabel,
    this.formLabelInfoField1,
    this.formLabelInfoField2,
    required this.dbTable,
    this.dateFormat = 'dd MMM yyyy',
    this.ruler = false,
  });

  int allRequired() =>
      fields
          .where((c) => c.isMandatory == true)
          .toList()
          .length;

  int filledRequired() {
    int count = 0;
    for (int i = 0; i < fields.length; i++) {
      if (fields[i].isMandatory) {
        if (fields[i].type == FieldType.radio ||
            fields[i].type == FieldType.string ||
            fields[i].type == FieldType.date) {
          if (fields[i].stringValue != '' || fields[i].intValue >= 0) {
            count++;
          }
        } else if (fields[i].type == FieldType.signature) {
          if (fields[i].signature != null && fields[i].signature!.isNotEmpty) {
            count++;
          }
        } else if (fields[i].type == FieldType.int && fields[i].intValue >= 0) {
          count++;
        } else if (fields[i].type == FieldType.checkbox) {
          if (fields[i].checkBoxValue.contains(true)) {
            count++;
          }
        }
      }
    }
    return count;
  }

  double percentFilled() {
    int allRequired = fields
        .where((c) => c.isMandatory)
        .toList()
        .length;
    // int filledRequired = fields
    //     .where(
    //       (c) =>
    //           c.isMandatory &&
    //               ((c.type == FieldType.radio ||
    //                           c.type == FieldType.string ||
    //                           c.type == FieldType.date) &&
    //                       c.stringValue != '' ||
    //                   c.intValue >= 0) ||
    //           (c.type == FieldType.signature &&
    //               c.signature != null &&
    //               c.signature!.isNotEmpty) ||
    //           (c.type == FieldType.int && c.intValue >= 0) ||
    //           (c.type == FieldType.checkbox && c.checkBoxValue.contains(true)),
    //     )
    //     .toList()
    //     .length;

    print('filledRequired is: ${filledRequired()}');
    print('allRequired is: $allRequired');
    double percent = (filledRequired() / allRequired) * 100;
    print('percent is: $percent');
    return percent;
  }

  String getStrVal(String name) {
    try {
      Log.add('Search str val for "$name" in form " $formName"');
      return fields[fields.indexWhere((e) => e.name == name)].stringValue;
    } catch (e) {
      Log.add('ERROR WHEN SEARCH STRING VALUE FOR $name IN FORM $formName');
      return "ERROR";
    }
  }

  String getDateStrVal(String name, String format) {
    try {
      Log.add('Search str val for "$name" in form " $formName"');
      DateTime date = fields[fields.indexWhere((e) => e.name == name)]
          .dateTimeValue as DateTime;
      return DateFormat(format).format(date);
    } catch (e) {
      Log.add('ERROR WHEN SEARCH STRING VALUE FOR $name IN FORM $formName');
      return "ERROR";
    }
  }

  /// Generic field→map builder used by every current (main-menu) form type.
  ///
  /// Every hand-written `toMap()` was really just: a constant header block,
  /// plus one `'<name>': getStrVal('<name>')` line per field. This reproduces
  /// that mechanically, so new/edited forms don't need a hand-written mapping.
  ///
  /// Fields are skipped when they have no [Field.name] (display-only
  /// `duplicateFrom` fields), or are a [FieldType.checkbox] (whose data is
  /// carried by their `<name>_N` string mirror fields, which are emitted), or
  /// are a [FieldType.signature] (uploaded as an image, never a sheet column).
  Map<String, dynamic> defaultMap() {
    final Map<String, dynamic> map = {
      'status': status.toString(),
      'type': type.toString(),
      'form_name': formName,
      'create_at': createDateTime.toString(),
      'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
      'create_by': createBy,
      'file_path': filePath,
      'id': id,
      'font_size': fontSize.round().toString(),
      'pdf_url': pdfUrl ?? '',
    };
    for (final field in fields) {
      if (field.name.isEmpty) continue;
      if (field.type == FieldType.checkbox) continue;
      if (field.type == FieldType.signature) continue;
      map[field.name] = getStrVal(field.name);
    }
    return map;
  }

  ///Convert field values into a mapping table for database and Google Sheet.
  ///todo: New form step 6 — add the new FormType to the group below so it uses
  ///the generic [defaultMap]. No hand-written mapping needed; only add a
  ///special case if the form genuinely can't be expressed by the generic rule.
  Map<String, dynamic> formMap() {
    switch (type) {
    // Active (main-menu) forms use the generic mapper — no hand-written
    // toMap() to maintain.
      case FormType.fcss:
      case FormType.lineCheck5:
      case FormType.ppc6:
      case FormType.ppc8:
      case FormType.rt3:
      case FormType.rt4:
      case FormType.lineTrain:
      case FormType.stdloft:
      case FormType.diff:
        return defaultMap();

    // sample: demo account, never submitted.
      default:
        return {};
    }
  }

  ///todo: New form step 11 (optional) — add cross-field validation here if needed.
  String validate() {
    String result = '';

    ///validate field input
    if (type == FormType.lineTrain) {
      fields[fields.indexWhere((e) => e.name == 'ac_reg_1')].stringValue =
          fields[fields.indexWhere((e) => e.name == 'ac_reg_1')]
              .stringValue
              .replaceFirst('HS-', '');
      fields[fields.indexWhere((e) => e.name == 'ac_reg_2')].stringValue =
          fields[fields.indexWhere((e) => e.name == 'ac_reg_2')]
              .stringValue
              .replaceFirst('HS-', '');
      fields[fields.indexWhere((e) => e.name == 'flt_no_1')].stringValue =
          fields[fields.indexWhere((e) => e.name == 'flt_no_1')]
              .stringValue
              .replaceAll('VZ', '')
              .trim();
      fields[fields.indexWhere((e) => e.name == 'flt_no_1')].stringValue =
          fields[fields.indexWhere((e) => e.name == 'flt_no_1')]
              .stringValue
              .replaceAll('TVJ', '')
              .trim();
      fields[fields.indexWhere((e) => e.name == 'flt_no_2')].stringValue =
          fields[fields.indexWhere((e) => e.name == 'flt_no_2')]
              .stringValue
              .replaceAll('VZ', '')
              .trim();
      fields[fields.indexWhere((e) => e.name == 'flt_no_2')].stringValue =
          fields[fields.indexWhere((e) => e.name == 'flt_no_2')]
              .stringValue
              .replaceAll('TVJ', '')
              .trim();
    }

    ///Validate line train examiner signature if required
    if (type == FormType.lineTrain) {
      print('validating line train form');
      //Check if examiner signature is required and missing?
      if ((fields[fields.indexWhere((e) => e.name == 'check_type_5')]
          .stringValue ==
          'true' ||
          fields[fields.indexWhere((e) => e.name == 'check_type_6')]
              .stringValue ==
              'true') &&
          (fields[fields.indexWhere((e) => e.name == 'examiner_name')]
              .stringValue
              .isEmpty ||
              fields[
              fields.indexWhere((e) => e.name == 'examiner_sig')]
                  .signature ==
                  null ||
              fields[fields.indexWhere((e) => e.name == 'examiner_sig')]
                  .signature!
                  .isEmpty ||
              fields[fields.indexWhere((e) => e.name == 'examiner_result')]
                  .stringValue ==
                  '' ||
              fields[fields.indexWhere((e) => e.name == 'examiner_sig_date')]
                  .stringValue ==
                  kBlankText)) {
        result =
        'Examiner details/signature/result are required for check flight.';
      }
    }
    return result;
  }
}