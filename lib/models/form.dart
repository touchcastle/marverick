import 'package:flutter/cupertino.dart';
import 'package:marverick/models/field.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/services/log.dart';
import 'package:marverick/services/forms/ccc_form.dart';
import 'package:marverick/services/forms/fcss_form.dart';
import 'package:marverick/services/forms/line_check5_form.dart';
import 'package:marverick/services/forms/line_check_form.dart';
import 'package:marverick/services/forms/line_train_form.dart';
import 'package:marverick/services/forms/ppc5_form.dart';
import 'package:marverick/services/forms/ppc6_form.dart';
import 'package:marverick/services/forms/ppc8_form.dart';
import 'package:marverick/services/forms/psc_form.dart';
import 'package:marverick/services/forms/rt1_form.dart';
import 'package:marverick/services/forms/rt22_form.dart';
import 'package:marverick/services/forms/rt2_form.dart';
import 'package:marverick/services/forms/rt3_form.dart';
import 'package:marverick/services/forms/rt4_form.dart';
import 'package:marverick/services/forms/stdloft_form.dart';
import 'package:intl/intl.dart';

///TODO: New form (1): Add new type
///TODO: New form (13): Add new form in Google Sheet + macro
enum FormType {
  loe,
  lineCheck,
  lineCheck5,
  sample,
  ppc,
  ppc5,
  ppc6,
  ppc8,
  stdloft, //Standard LOFT (a320/b737)
  rt1,
  rt2,
  rt22,
  rt3,
  rt4,
  rt5,
  rt6,
  lineTrain,
  ccc, //Cabin Crew Line Train/Check
  psc, //Purser Upgrade Train/Check
  fcss, //Flight Crew Simulator Screening
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
      fields.where((c) => c.isMandatory == true).toList().length;

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
    int allRequired = fields.where((c) => c.isMandatory).toList().length;
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

  ///Convert field values into a mapping table for database and Google Sheet.
  ///TODO: New form (4): Add new mapping in services/forms/<type>_form.dart
  Map<String, dynamic> formMap() {
    switch (type) {
      case FormType.lineCheck:
        return LineCheckForm.toMap(this);
      case FormType.lineCheck5:
        return LineCheck5Form.toMap(this);
      case FormType.ppc5:
        return Ppc5Form.toMap(this);
      case FormType.ppc6:
        return Ppc6Form.toMap(this);
      case FormType.ppc8:
        return Ppc8Form.toMap(this);
      case FormType.rt1:
        return Rt1Form.toMap(this);
      case FormType.rt2:
        return Rt2Form.toMap(this);
      case FormType.rt22:
        return Rt22Form.toMap(this);
      case FormType.rt3:
        return Rt3Form.toMap(this);
      case FormType.rt4:
        return Rt4Form.toMap(this);
      case FormType.stdloft:
        return StdloftForm.toMap(this);
      case FormType.lineTrain:
        return LineTrainForm.toMap(this);
      case FormType.ccc:
        return CccForm.toMap(this);
      case FormType.psc:
        return PscForm.toMap(this);
      case FormType.fcss:
        return FcssForm.toMap(this);
      default:
        return {};
    }
  }

  ///TODO: New form (10): Add validation (if any)
  String validate() {
    String result = '';

    ///validate field input
    if (type == FormType.lineCheck || type == FormType.lineTrain) {
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
      if ((fields[fields.indexWhere((e) => e.name == 'check_type_5')].stringValue ==
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