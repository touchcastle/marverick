import 'package:flutter/cupertino.dart';
import 'package:marverick/models/field.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/services/log.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

///TODO: New form (1): Add new type
///TODO: New form (13): Add new form in Google Sheet + macro
enum FormType {
  loe,
  lineCheck,
  sample,
  ppc,
  ppc5,
  ppc6,
  rt1,
  rt2,
  rt5,
  rt6,
  lineTrain,
  ccc, //Cabin Crew Line Train/Check
  psc, //Purser Upgrade Train/Check
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

  /// Section label as in PDF
  List<String> sectionLabel;

  /// Grading section label as in PDF
  List<String>? gradeSectionLabel;

  /// for display form list in main screen
  String formLabel;
  String? formLabelInfoField1;
  String? formLabelInfoField2;
  String? pdfUrl;

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

  // Method to make GET parameters.
  // Map<String, dynamic> lineCheckToMap() {
  ///TODO: New form (4): Add new mapping
  ///Convert list into mapping table for database and google sheet
  Map<String, dynamic> formMap() {
    ///NEW LOGIC
    if (type == FormType.lineCheck) {
      return {
        //----------------------------------------------------------------------
        //HEADER
        //----------------------------------------------------------------------
        //Form info.
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
        //----------------------------------------------------------------------
        //ITEM
        //----------------------------------------------------------------------
        //Pilot info.
        'pilot_rank': getStrVal('pilot_rank'),
        'pilot_id': getStrVal('pilot_id'),
        'pilot_license_no': getStrVal('pilot_license_no'),
        'pilot_name': getStrVal('pilot_name'),

        //Examiner info.
        'examiner_rank': getStrVal('examiner_rank'),
        'examiner_id': getStrVal('examiner_id'),
        'examiner_license_no': getStrVal('examiner_license_no'),
        'examiner_name': getStrVal('examiner_name'),

        //Check type
        'type_of_check': getStrVal('type_of_check'),
        'other_type': getStrVal('other_type'),

        //Sector#1
        'date_1': getStrVal('date_1'),
        'ac_type_1': getStrVal('ac_type_1'),
        'ac_reg_1': getStrVal('ac_reg_1'),
        'flt_no_1': getStrVal('flt_no_1'),
        'from_1': getStrVal('from_1'),
        'to_1': getStrVal('to_1'),
        'duty_1': getStrVal('duty_1'),

        //Sector#2
        'date_2': getStrVal('date_2'),
        'ac_type_2': getStrVal('ac_type_2'),
        'ac_reg_2': getStrVal('ac_reg_2'),
        'flt_no_2': getStrVal('flt_no_2'),
        'from_2': getStrVal('from_2'),
        'to_2': getStrVal('to_2'),
        'duty_2': getStrVal('duty_2'),

        //Grading & Comment
        //A
        'a_1': getStrVal('a_1'),
        'a_2': getStrVal('a_2'),
        'a_3': getStrVal('a_3'),
        'a_4': getStrVal('a_4'),
        'a_5': getStrVal('a_5'),
        'a_6': getStrVal('a_6'),
        'a_7': getStrVal('a_7'),
        'a_comment': getStrVal('a_comment'),
        //B
        'b_8': getStrVal('b_8'),
        'b_9': getStrVal('b_9'),
        'b_10': getStrVal('b_10'),
        'b_11': getStrVal('b_11'),
        'b_12': getStrVal('b_12'),
        'b_13': getStrVal('b_13'),
        'b_comment': getStrVal('b_comment'),
        //C
        'c_14': getStrVal('c_14'),
        'c_15': getStrVal('c_15'),
        'c_16': getStrVal('c_16'),
        'c_17': getStrVal('c_17'),
        'c_18': getStrVal('c_18'),
        'c_comment': getStrVal('c_comment'),
        //D
        'd_19': getStrVal('d_19'),
        'd_20': getStrVal('d_20'),
        'd_21': getStrVal('d_21'),
        'd_22': getStrVal('d_22'),
        'd_23': getStrVal('d_23'),
        'd_24': getStrVal('d_24'),
        'd_25': getStrVal('d_25'),
        'd_26': getStrVal('d_26'),
        'd_27': getStrVal('d_27'),
        'd_28': getStrVal('d_28'),
        'd_comment': getStrVal('d_comment'),
        //E
        'e_29': getStrVal('e_29'),
        'e_30': getStrVal('e_30'),
        'e_31': getStrVal('e_31'),
        'e_32': getStrVal('e_32'),
        'e_33': getStrVal('e_33'),
        'e_34': getStrVal('e_34'),
        'e_comment': getStrVal('e_comment'),
        //BRIEFING
        'brief_1': getStrVal('brief_1'),
        'brief_2': getStrVal('brief_2'),
        'brief_3': getStrVal('brief_3'),
        'brief_4': getStrVal('brief_4'),
        'brief_5': getStrVal('brief_5'),
        'brief_comment': getStrVal('brief_comment'),
        //COMPETENCY
        'comp_pro': getStrVal('comp_pro'),
        'comp_com': getStrVal('comp_com'),
        'comp_fpa': getStrVal('comp_fpa'),
        'comp_fpm': getStrVal('comp_fpm'),
        'comp_kno': getStrVal('comp_kno'),
        'comp_ltw': getStrVal('comp_ltw'),
        'comp_psd': getStrVal('comp_psd'),
        'comp_saw': getStrVal('comp_saw'),
        'comp_wlm': getStrVal('comp_wlm'),
        'general_comment': getStrVal('general_comment'),
        //RESULT
        'result': getStrVal('result'),
        'competent_level': getStrVal('competent_level'),
        'result_comment': getStrVal('result_comment'),

        'pilot_sig_date': getStrVal('pilot_sig_date'),
        'examiner_sig_date': getStrVal('examiner_sig_date'),
      };
    } else if (type == FormType.ppc) {
      return ({});
    } else if (type == FormType.ppc5) {
      return {
        ///----------------------------------------------------------------------
        ///HEADER
        ///----------------------------------------------------------------------
        ///Form info.
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

        ///----------------------------------------------------------------------
        ///ITEM
        ///----------------------------------------------------------------------
        ///Pilot info.
        'pilot_rank': getStrVal('pilot_rank'),
        'pilot_id': getStrVal('pilot_id'),
        'pilot_license_no': getStrVal('pilot_license_no'),
        'pilot_name': getStrVal('pilot_name'),

        //Instructor info.
        'instructor_rank': getStrVal('instructor_rank'),
        'instructor_id': getStrVal('instructor_id'),
        'instructor_cert_no': getStrVal('instructor_cert_no'),
        'instructor_name': getStrVal('instructor_name'),

        ///Examiner info.
        'examiner_type': getStrVal('examiner_type'),
        'examiner_id': getStrVal('examiner_id'),
        'examiner_pel_no': getStrVal('examiner_pel_no'),
        'examiner_name': getStrVal('examiner_name'),

        ///Check details
        'check_date': getStrVal('check_date'),
        'block_time': getStrVal('block_time'),
        'fstd_no': getStrVal('fstd_no'),
        'route': getStrVal('route'),
        'check_type_0': getStrVal('check_type_0'),
        'check_type_1': getStrVal('check_type_1'),
        'check_type_2': getStrVal('check_type_2'),
        'check_type_3': getStrVal('check_type_3'),

        ///Grading & Comment
        'q1': getStrVal('q1'),
        'q2_detail': getStrVal('q2_detail'),
        'q2': getStrVal('q2'),
        'q3': getStrVal('q3'),
        'q4': getStrVal('q4'),
        'q5': getStrVal('q5'),
        'q6': getStrVal('q6'),
        'q7': getStrVal('q7'),
        'q8': getStrVal('q8'),
        'q9': getStrVal('q9'),
        'q10': getStrVal('q10'),
        'q11_check_0': getStrVal('q11_check_0'),
        'q11_check_1': getStrVal('q11_check_1'),
        'q11': getStrVal('q11'),
        'q12': getStrVal('q12'),
        'q13_check_0': getStrVal('q13_check_0'),
        'q13_check_1': getStrVal('q13_check_1'),
        'q13_check_2': getStrVal('q13_check_2'),
        'q13': getStrVal('q13'),
        'q14': getStrVal('q14'),
        'q15': getStrVal('q15'),
        'q16_check_0': getStrVal('q16_check_0'),
        'q16_check_1': getStrVal('q16_check_1'),
        'q16': getStrVal('q16'),
        'q17': getStrVal('q17'),
        'q18': getStrVal('q18'),
        'q19': getStrVal('q19'),
        'q20': getStrVal('q20'),
        'q21': getStrVal('q21'),
        'q22': getStrVal('q22'),
        'q23': getStrVal('q23'),
        'q24': getStrVal('q24'),
        'q25': getStrVal('q25'),
        'q26': getStrVal('q26'),
        'q27': getStrVal('q27'),
        'q28': getStrVal('q28'),
        'q29': getStrVal('q29'),
        'q30': getStrVal('q30'),
        'q31': getStrVal('q31'),
        'q32': getStrVal('q32'),
        'q33': getStrVal('q33'),
        'q34': getStrVal('q34'),
        'q35': getStrVal('q35'),
        'q36': getStrVal('q36'),
        'q37': getStrVal('q37'),
        'q38': getStrVal('q38'),
        'q39': getStrVal('q39'),
        'q40': getStrVal('q40'),
        'q41': getStrVal('q41'),
        'q42': getStrVal('q42'),
        'q43': getStrVal('q43'),
        'q44': getStrVal('q44'),
        'q45': getStrVal('q45'),
        'q46': getStrVal('q46'),
        'q47': getStrVal('q47'),
        'q48': getStrVal('q48'),
        'q49': getStrVal('q49'),
        'q50': getStrVal('q50'),
        'q51': getStrVal('q51'),
        'q52': getStrVal('q52'),
        'q53': getStrVal('q53'),
        'q54_detail': getStrVal('q54_detail'),
        'q54': getStrVal('q54'),
        'q55_detail': getStrVal('q55_detail'),
        'q55': getStrVal('q55'),
        'q56_detail': getStrVal('q56_detail'),
        'q56': getStrVal('q56'),
        'q57_detail': getStrVal('q57_detail'),
        'q57': getStrVal('q57'),
        'q58_detail': getStrVal('q58_detail'),
        'q58': getStrVal('q58'),

        'qa_comment': getStrVal('qa_comment'),
        'qb_comment': getStrVal('qb_comment'),
        'qc_comment': getStrVal('qc_comment'),
        'qd_comment': getStrVal('qd_comment'),
        'qe_comment': getStrVal('qe_comment'),
        'qf_comment': getStrVal('qf_comment'),
        'qg_comment': getStrVal('qg_comment'),
        'qh_comment': getStrVal('qh_comment'),
        'qi_comment': getStrVal('qi_comment'),
        'qj_comment': getStrVal('qj_comment'),

        ///LANDING AND GO-AROUND
        'no_landing': getStrVal('no_landing'),
        'no_goaround': getStrVal('no_goaround'),

        ///COMPETENCY
        'comp_kno': getStrVal('comp_kno'),
        'comp_pro': getStrVal('comp_pro'),
        'comp_com': getStrVal('comp_com'),
        'comp_fpa': getStrVal('comp_fpa'),
        'comp_fpm': getStrVal('comp_fpm'),
        'comp_ltw': getStrVal('comp_ltw'),
        'comp_psd': getStrVal('comp_psd'),
        'comp_saw': getStrVal('comp_saw'),
        'comp_wlm': getStrVal('comp_wlm'),
        'general_comment': getStrVal('general_comment'),
        //RESULT
        'result': getStrVal('result'),

        // 'pilot_sig_date': getStrVal('pilot_sig_date'),
        // 'examiner_sig_date': getStrVal('examiner_sig_date'),
      };
    } else if (type == FormType.ppc6) {
      return {
        ///----------------------------------------------------------------------
        ///HEADER
        ///----------------------------------------------------------------------
        ///Form info.
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

        ///----------------------------------------------------------------------
        ///ITEM
        ///----------------------------------------------------------------------
        ///Pilot info.
        'pilot_rank': getStrVal('pilot_rank'),
        'pilot_id': getStrVal('pilot_id'),
        'pilot_license_no': getStrVal('pilot_license_no'),
        'pilot_name': getStrVal('pilot_name'),

        //Instructor info.
        'instructor_rank': getStrVal('instructor_rank'),
        'instructor_id': getStrVal('instructor_id'),
        'instructor_cert_no': getStrVal('instructor_cert_no'),
        'instructor_name': getStrVal('instructor_name'),

        ///Examiner info.
        'examiner_type': getStrVal('examiner_type'),
        'examiner_id': getStrVal('examiner_id'),
        'examiner_pel_no': getStrVal('examiner_pel_no'),
        'examiner_name': getStrVal('examiner_name'),

        ///Check details
        'check_date': getStrVal('check_date'),
        'block_time': getStrVal('block_time'),
        'fstd_no': getStrVal('fstd_no'),
        'route': getStrVal('route'),
        'ac_type': getStrVal('ac_type'),
        'check_type_0': getStrVal('check_type_0'),
        'check_type_1': getStrVal('check_type_1'),
        'check_type_2': getStrVal('check_type_2'),
        'check_type_3': getStrVal('check_type_3'),

        ///Grading & Comment
        'q1': getStrVal('q1'),
        'q2': getStrVal('q2'),
        'q3_detail': getStrVal('q3_detail'),
        'q3': getStrVal('q3'),
        'q4': getStrVal('q4'),
        'q5': getStrVal('q5'),
        'q6': getStrVal('q6'),
        'q7': getStrVal('q7'),
        'q8': getStrVal('q8'),
        'q9': getStrVal('q9'),
        'q10': getStrVal('q10'),
        'q11': getStrVal('q11'),
        'q12_check_0': getStrVal('q12_check_0'),
        'q12_check_1': getStrVal('q12_check_1'),
        'q12': getStrVal('q12'),
        'q13': getStrVal('q13'),
        'q14_check_0': getStrVal('q14_check_0'),
        'q14_check_1': getStrVal('q14_check_1'),
        'q14_check_2': getStrVal('q14_check_2'),
        'q14': getStrVal('q14'),
        'q15': getStrVal('q15'),
        'q16': getStrVal('q16'),
        'q17_check_0': getStrVal('q17_check_0'),
        'q17_check_1': getStrVal('q17_check_1'),
        'q17': getStrVal('q17'),
        'q18': getStrVal('q18'),
        'q19': getStrVal('q19'),
        'q20': getStrVal('q20'),
        'q21': getStrVal('q21'),
        'q22': getStrVal('q22'),
        'q23': getStrVal('q23'),
        'q24': getStrVal('q24'),
        'q25': getStrVal('q25'),
        'q26': getStrVal('q26'),
        'q27': getStrVal('q27'),
        'q28': getStrVal('q28'),
        'q29': getStrVal('q29'),
        'q30': getStrVal('q30'),
        'q31': getStrVal('q31'),
        'q32': getStrVal('q32'),
        'q33': getStrVal('q33'),
        'q34': getStrVal('q34'),
        'q35': getStrVal('q35'),
        'q36': getStrVal('q36'),
        'q37': getStrVal('q37'),
        'q38': getStrVal('q38'),
        'q39': getStrVal('q39'),
        'q40': getStrVal('q40'),
        'q41': getStrVal('q41'),
        'q42': getStrVal('q42'),
        'q43': getStrVal('q43'),
        'q44': getStrVal('q44'),
        'q45': getStrVal('q45'),
        'q46': getStrVal('q46'),
        'q47': getStrVal('q47'),
        'q48': getStrVal('q48'),
        'q49': getStrVal('q49'),
        'q50': getStrVal('q50'),
        'q51': getStrVal('q51'),
        'q52': getStrVal('q52'),
        'q53': getStrVal('q53'),
        'q54': getStrVal('q54'),
        'q55': getStrVal('q55'),
        'q56_detail': getStrVal('q56_detail'),
        'q56': getStrVal('q56'),
        'q57_detail': getStrVal('q57_detail'),
        'q57': getStrVal('q57'),
        'q58_detail': getStrVal('q58_detail'),
        'q58': getStrVal('q58'),

        'qa_comment': getStrVal('qa_comment'),
        'qb_comment': getStrVal('qb_comment'),
        'qc_comment': getStrVal('qc_comment'),
        'qd_comment': getStrVal('qd_comment'),
        'qe_comment': getStrVal('qe_comment'),
        'qf_comment': getStrVal('qf_comment'),
        'qg_comment': getStrVal('qg_comment'),
        'qh_comment': getStrVal('qh_comment'),
        'qi_comment': getStrVal('qi_comment'),
        'qj_comment': getStrVal('qj_comment'),

        ///LANDING AND GO-AROUND
        'no_landing': getStrVal('no_landing'),
        'no_goaround': getStrVal('no_goaround'),

        ///COMPETENCY
        'comp_kno': getStrVal('comp_kno'),
        'comp_pro': getStrVal('comp_pro'),
        'comp_com': getStrVal('comp_com'),
        'comp_fpa': getStrVal('comp_fpa'),
        'comp_fpm': getStrVal('comp_fpm'),
        'comp_ltw': getStrVal('comp_ltw'),
        'comp_psd': getStrVal('comp_psd'),
        'comp_saw': getStrVal('comp_saw'),
        'comp_wlm': getStrVal('comp_wlm'),
        'general_comment': getStrVal('general_comment'),
        //RESULT
        'result': getStrVal('result'),

        // 'pilot_sig_date': getStrVal('pilot_sig_date'),
        // 'examiner_sig_date': getStrVal('examiner_sig_date'),
      };
    }else if (type == FormType.rt1) {
      return {
        ///----------------------------------------------------------------------
        ///HEADER
        ///----------------------------------------------------------------------
        ///Form info.
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

        ///----------------------------------------------------------------------
        ///ITEM
        ///----------------------------------------------------------------------
        ///Pilot info.
        'pilot_rank': getStrVal('pilot_rank'),
        'pilot_name': getStrVal('pilot_name'),
        'pilot_license_no': getStrVal('pilot_license_no'),
        'pilot_id': getStrVal('pilot_id'),

        ///Instructor info.
        'instructor_rank': getStrVal('instructor_rank'),
        'instructor_name': getStrVal('instructor_name'),
        'instructor_cert_no': getStrVal('instructor_cert_no'),
        'instructor_id': getStrVal('instructor_id'),

        ///Check details
        'check_date': getStrVal('check_date'),
        'block_time': getStrVal('block_time'),
        'fstd_no': getStrVal('fstd_no'),
        'loft_duty': getStrVal('loft_duty'),

        ///Grading & Comment
        ///A
        'q1': getStrVal('q1'),
        'q2': getStrVal('q2'),
        'q3': getStrVal('q3'),
        'q4': getStrVal('q4'),
        'q5': getStrVal('q5'),
        'q6_detail': getStrVal('q6_detail'),
        'q6': getStrVal('q6'),
        'q7': getStrVal('q7'),
        'q8': getStrVal('q8'),
        'q9': getStrVal('q9'),
        'q10': getStrVal('q10'),
        'q11': getStrVal('q11'),
        'q12': getStrVal('q12'),
        'q13': getStrVal('q13'),
        'q14': getStrVal('q14'),
        'q15': getStrVal('q15'),
        'q16': getStrVal('q16'),
        'q17': getStrVal('q17'),
        'q18': getStrVal('q18'),
        'q19': getStrVal('q19'),
        'q20_check_0': getStrVal('q20_check_0'),
        'q20_check_1': getStrVal('q20_check_1'),
        'q20_check_2': getStrVal('q20_check_2'),
        'q20': getStrVal('q20'),
        'q21_check_0': getStrVal('q21_check_0'),
        'q21_check_1': getStrVal('q21_check_1'),
        'q21': getStrVal('q21'),
        'q22': getStrVal('q22'),
        'q23': getStrVal('q23'),
        'q24': getStrVal('q24'),
        'q25': getStrVal('q25'),
        'q26': getStrVal('q26'),
        'q27': getStrVal('q27'),
        'q28': getStrVal('q28'),
        'q29': getStrVal('q29'),
        'q30': getStrVal('q30'),
        'q31': getStrVal('q31'),
        'q32': getStrVal('q32'),
        'q33': getStrVal('q33'),
        'q34': getStrVal('q34'),
        'q35': getStrVal('q35'),
        'q36': getStrVal('q36'),
        'q37': getStrVal('q37'),
        'q38': getStrVal('q38'),
        'q39': getStrVal('q39'),
        'q40': getStrVal('q40'),
        'q41': getStrVal('q41'),
        'q42': getStrVal('q42'),
        'q43': getStrVal('q43'),
        'q44': getStrVal('q44'),
        'q45': getStrVal('q45'),
        'q46': getStrVal('q46'),
        'q47': getStrVal('q47'),
        'q48': getStrVal('q48'),
        'q49': getStrVal('q49'),
        'q50': getStrVal('q50'),
        'q51': getStrVal('q51'),
        'q52_detail': getStrVal('q52_detail'),
        'q52': getStrVal('q52'),
        'q53_detail': getStrVal('q53_detail'),
        'q53': getStrVal('q53'),
        'q54_detail': getStrVal('q54_detail'),
        'q54': getStrVal('q54'),
        'q55_detail': getStrVal('q55_detail'),
        'q55': getStrVal('q55'),

        'qa_comment': getStrVal('qa_comment'),
        'qb_comment': getStrVal('qb_comment'),
        'qc_comment': getStrVal('qc_comment'),
        'qd_comment': getStrVal('qd_comment'),
        'qe_comment': getStrVal('qe_comment'),
        'qg_comment': getStrVal('qg_comment'),
        'qh_comment': getStrVal('qh_comment'),
        'qi_comment': getStrVal('qi_comment'),
        'qj_comment': getStrVal('qj_comment'),
        'qk_comment': getStrVal('qk_comment'),

        ///LANDING AND GO-AROUND
        'no_landing': getStrVal('no_landing'),
        'no_goaround': getStrVal('no_goaround'),

        ///COMPETENCY
        'comp_kno': getStrVal('comp_kno'),
        'comp_pro': getStrVal('comp_pro'),
        'comp_com': getStrVal('comp_com'),
        'comp_fpa': getStrVal('comp_fpa'),
        'comp_fpm': getStrVal('comp_fpm'),
        'comp_ltw': getStrVal('comp_ltw'),
        'comp_psd': getStrVal('comp_psd'),
        'comp_saw': getStrVal('comp_saw'),
        'comp_wlm': getStrVal('comp_wlm'),
        'general_comment': getStrVal('general_comment'),

        ///RESULT
        'result': getStrVal('result'),
        // 'pilot_sig_date': getStrVal('pilot_sig_date'),
        // 'instructor_sig_date': getStrVal('instructor_sig_date'),
      };
    } else if (type == FormType.rt2) {
      return {
        ///----------------------------------------------------------------------
        ///HEADER
        ///----------------------------------------------------------------------
        ///Form info.
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

        ///----------------------------------------------------------------------
        ///ITEM
        ///----------------------------------------------------------------------
        ///Pilot info.
        'pilot_rank': getStrVal('pilot_rank'),
        'pilot_name': getStrVal('pilot_name'),
        'pilot_license_no': getStrVal('pilot_license_no'),
        'pilot_id': getStrVal('pilot_id'),

        ///Instructor info.
        'instructor_rank': getStrVal('instructor_rank'),
        'instructor_name': getStrVal('instructor_name'),
        'instructor_cert_no': getStrVal('instructor_cert_no'),
        'instructor_id': getStrVal('instructor_id'),

        ///Check details
        'check_date': getStrVal('check_date'),
        'block_time': getStrVal('block_time'),
        'fstd_no': getStrVal('fstd_no'),
        'ac_type': getStrVal('ac_type'),
        'loft_duty': getStrVal('loft_duty'),

        ///Grading & Comment
        ///A
        'q1': getStrVal('q1'),
        'q2': getStrVal('q2'),
        'q3': getStrVal('q3'),
        'q4': getStrVal('q4'),
        'q5': getStrVal('q5'),
        'q6_detail': getStrVal('q6_detail'),
        'q6': getStrVal('q6'),
        'q7': getStrVal('q7'),
        'q8': getStrVal('q8'),
        'q9': getStrVal('q9'),
        'q10': getStrVal('q10'),
        'q11': getStrVal('q11'),
        'q12': getStrVal('q12'),
        'q13': getStrVal('q13'),
        'q14_check_0': getStrVal('q14_check_0'),
        'q14_check_1': getStrVal('q14_check_1'),
        'q14': getStrVal('q14'),
        'q15': getStrVal('q15'),
        'q16_check_0': getStrVal('q16_check_0'),
        'q16_check_1': getStrVal('q16_check_1'),
        'q16_check_2': getStrVal('q16_check_2'),
        'q16': getStrVal('q16'),
        'q17': getStrVal('q17'),
        'q18': getStrVal('q18'),
        'q19_check_0': getStrVal('q19_check_0'),
        'q19_check_1': getStrVal('q19_check_1'),
        'q19': getStrVal('q19'),
        'q20': getStrVal('q20'),
        'q21': getStrVal('q21'),
        'q22': getStrVal('q22'),
        'q23': getStrVal('q23'),
        'q24': getStrVal('q24'),
        'q25': getStrVal('q25'),
        'q26': getStrVal('q26'),
        'q27_check_0': getStrVal('q27_check_0'),
        'q27_check_1': getStrVal('q27_check_1'),
        'q27_check_2': getStrVal('q27_check_2'),
        'q27': getStrVal('q27'),
        'q28_check_0': getStrVal('q28_check_0'),
        'q28_check_1': getStrVal('q28_check_1'),
        'q28_check_2': getStrVal('q28_check_2'),
        'q28': getStrVal('q28'),
        'q29_check_0': getStrVal('q29_check_0'),
        'q29_check_1': getStrVal('q29_check_1'),
        'q29_check_2': getStrVal('q29_check_2'),
        'q29': getStrVal('q29'),
        'q30': getStrVal('q30'),
        'q31': getStrVal('q31'),
        'q32': getStrVal('q32'),
        'q33': getStrVal('q33'),
        'q34': getStrVal('q34'),
        'q35': getStrVal('q35'),
        'q36': getStrVal('q36'),
        'q37': getStrVal('q37'),
        'q38': getStrVal('q38'),
        'q39': getStrVal('q39'),
        'q40': getStrVal('q40'),
        'q41': getStrVal('q41'),
        'q42': getStrVal('q42'),
        'q43': getStrVal('q43'),
        'q44': getStrVal('q44'),
        'q45': getStrVal('q45'),
        'q46': getStrVal('q46'),
        'q47': getStrVal('q47'),
        'q48': getStrVal('q48'),
        'q49': getStrVal('q49'),
        'q50': getStrVal('q50'),
        'q51': getStrVal('q51'),
        'q52': getStrVal('q52'),
        'q53': getStrVal('q53'),
        'q54': getStrVal('q54'),
        'q55': getStrVal('q55'),
        'q56': getStrVal('q56'),
        'q57': getStrVal('q57'),

        'qa_comment': getStrVal('qa_comment'),
        'qb_comment': getStrVal('qb_comment'),
        'qc_comment': getStrVal('qc_comment'),
        'qd_comment': getStrVal('qd_comment'),
        'qe_comment': getStrVal('qe_comment'),
        'qg_comment': getStrVal('qg_comment'),
        'qh_comment': getStrVal('qh_comment'),
        'qi_comment': getStrVal('qi_comment'),
        'qj_comment': getStrVal('qj_comment'),
        'qk_comment': getStrVal('qk_comment'),

        ///LANDING AND GO-AROUND
        'no_landing': getStrVal('no_landing'),
        'no_goaround': getStrVal('no_goaround'),

        ///COMPETENCY
        'comp_kno': getStrVal('comp_kno'),
        'comp_pro': getStrVal('comp_pro'),
        'comp_com': getStrVal('comp_com'),
        'comp_fpa': getStrVal('comp_fpa'),
        'comp_fpm': getStrVal('comp_fpm'),
        'comp_ltw': getStrVal('comp_ltw'),
        'comp_psd': getStrVal('comp_psd'),
        'comp_saw': getStrVal('comp_saw'),
        'comp_wlm': getStrVal('comp_wlm'),
        'general_comment': getStrVal('general_comment'),

        ///RESULT
        'result': getStrVal('result'),
        // 'pilot_sig_date': getStrVal('pilot_sig_date'),
        // 'instructor_sig_date': getStrVal('instructor_sig_date'),
      };
    } else if (type == FormType.rt5) {
      return ({});
    } else if (type == FormType.rt6) {
      return ({});
    } else if (type == FormType.lineTrain) {
      return {
        ///----------------------------------------------------------------------
        ///HEADER
        ///----------------------------------------------------------------------
        ///Form info.
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

        ///----------------------------------------------------------------------
        ///ITEM
        ///----------------------------------------------------------------------
        ///Pilot info.
        'pilot_name': getStrVal('pilot_name'),
        'pilot_license_no': getStrVal('pilot_license_no'),
        'pilot_id': getStrVal('pilot_id'),

        ///Instructor info.
        'instructor_name': getStrVal('instructor_name'),
        'instructor_cert_no': getStrVal('instructor_cert_no'),
        'instructor_id': getStrVal('instructor_id'),

        ///Examiner / CAAT info.
        'examiner_name': getStrVal('examiner_name'),
        'examiner_license_no': getStrVal('examiner_license_no'),
        'examiner_id': getStrVal('examiner_id'),

        ///Check details
        'course': getStrVal('TcourseJO'),
        'other_course': getStrVal('other_course'),
        'check_type_0': getStrVal('check_type_0'),
        'check_type_1': getStrVal('check_type_1'),
        'check_type_2': getStrVal('check_type_2'),
        'check_type_3': getStrVal('check_type_3'),
        'check_type_4': getStrVal('check_type_4'),
        'check_type_5': getStrVal('check_type_5'),
        'check_type_6': getStrVal('check_type_6'),
        'check_type_7': getStrVal('check_type_7'),
        'other_type': getStrVal('other_type'),

        ///Sector
        'date_1': getStrVal('date_1'),
        'ac_type_1': getStrVal('ac_type_1'),
        'ac_reg_1': getStrVal('ac_reg_1'),
        'flt_no_1': getStrVal('flt_no_1'),
        'route_1': getStrVal('route_1'),
        'duty_1': getStrVal('duty_1'),
        'date_2': getStrVal('date_2'),
        'ac_type_2': getStrVal('ac_type_2'),
        'ac_reg_2': getStrVal('ac_reg_2'),
        'flt_no_2': getStrVal('flt_no_2'),
        'route_2': getStrVal('route_2'),
        'duty_2': getStrVal('duty_2'),

        'accum_pf': getStrVal('accum_pf'),
        'accum_pm': getStrVal('accum_pm'),

        ///Grading & Comment
        'q1': getStrVal('q1'),
        'q2': getStrVal('q2'),
        'q3': getStrVal('q3'),
        'q4': getStrVal('q4'),
        'q5': getStrVal('q5'),
        'q6': getStrVal('q6'),
        'q7': getStrVal('q7'),
        'q8': getStrVal('q8'),
        'q9': getStrVal('q9'),
        'q10': getStrVal('q10'),
        'q11': getStrVal('q11'),
        'q12': getStrVal('q12'),
        'q13': getStrVal('q13'),
        'q14': getStrVal('q14'),
        'q15': getStrVal('q15'),
        'q16': getStrVal('q16'),
        'q17': getStrVal('q17'),
        'q18': getStrVal('q18'),
        'q19': getStrVal('q19'),
        'q20': getStrVal('q20'),
        'q21': getStrVal('q21'),
        'q22': getStrVal('q22'),
        'q23': getStrVal('q23'),
        'q24': getStrVal('q24'),
        'q25': getStrVal('q25'),
        'q26': getStrVal('q26'),
        'q27': getStrVal('q27'),
        'q28': getStrVal('q28'),
        'q29': getStrVal('q29'),
        'q30': getStrVal('q30'),
        'q31': getStrVal('q31'),
        'q32': getStrVal('q32'),
        'q33': getStrVal('q33'),
        'q34': getStrVal('q34'),
        'q35': getStrVal('q35'),
        'q36': getStrVal('q36'),
        'q37_detail': getStrVal('q37_detail'),
        'q37': getStrVal('q37'),
        'q38_detail': getStrVal('q38_detail'),
        'q38': getStrVal('q38'),
        'q39_detail': getStrVal('q39_detail'),
        'q39': getStrVal('q39'),
        'q40_detail': getStrVal('q40_detail'),
        'q40': getStrVal('q40'),

        'qa_comment': getStrVal('qa_comment'),
        'qb_comment': getStrVal('qb_comment'),
        'qc_comment': getStrVal('qc_comment'),
        'qd_comment': getStrVal('qd_comment'),
        'qe_comment': getStrVal('qe_comment'),
        'qf_comment': getStrVal('qf_comment'),
        'qg_comment': getStrVal('qg_comment'),

        ///COMPETENCY
        'comp_kno': getStrVal('comp_kno'),
        'comp_pro': getStrVal('comp_pro'),
        'comp_com': getStrVal('comp_com'),
        'comp_fpa': getStrVal('comp_fpa'),
        'comp_fpm': getStrVal('comp_fpm'),
        'comp_ltw': getStrVal('comp_ltw'),
        'comp_psd': getStrVal('comp_psd'),
        'comp_saw': getStrVal('comp_saw'),
        'comp_wlm': getStrVal('comp_wlm'),
        'general_comment': getStrVal('general_comment'),
        'additional_note': getStrVal('additional_note'),

        ///RESULT
        'result': getStrVal('result'),
        'examiner_result': getStrVal('examiner_result'),
        // 'pilot_sig_date': getStrVal('pilot_sig_date'),
        // 'instructor_sig_date': getStrVal('instructor_sig_date'),
        'examiner_sig_date': getStrVal('examiner_sig_date'),
      };
    } else if (type == FormType.ccc) {
      return {
        ///----------------------------------------------------------------------
        ///HEADER
        ///----------------------------------------------------------------------
        ///Form info.
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

        ///----------------------------------------------------------------------
        ///ITEM
        ///----------------------------------------------------------------------
        ///Trainee info.
        'trainee_name': getStrVal('trainee_name'),
        'trainee_id': getStrVal('trainee_id'),

        ///Purser info.
        'purser_name': getStrVal('purser_name'),
        'purser_id': getStrVal('purser_id'),

        ///Evaluator
        'evaluator_name': getStrVal('evaluator_name'),
        'evaluator_id': getStrVal('evaluator_id'),

        ///Flight details
        'check_date': getStrVal('check_date'),
        'check_course': getStrVal('check_course'),
        'other_course': getStrVal('other_course'),
        'check_type': getStrVal('check_type'),
        'position': getStrVal('position'),
        'ac_type': getStrVal('ac_type'),
        'ac_reg': getStrVal('ac_reg'),
        'flight': getStrVal('flight'),
        'route': getStrVal('route'),

        ///Grading & Comment
        ///A
        'q1': getStrVal('q1s'),
        'q2': getStrVal('q2'),
        'q3': getStrVal('q3'),
        'q4': getStrVal('q4'),
        'q5': getStrVal('q5'),
        'q6': getStrVal('q6'),
        'q7': getStrVal('q7'),
        'q8': getStrVal('q8'),
        'q9': getStrVal('q9'),
        'q10': getStrVal('q10'),
        'q11': getStrVal('q11'),
        'q12': getStrVal('q12'),
        'q13': getStrVal('q13'),
        'q14': getStrVal('q14'),
        'q15': getStrVal('q15'),
        'q16': getStrVal('q16'),
        'q17': getStrVal('q17'),
        'q18': getStrVal('q18'),
        'q19': getStrVal('q19'),
        'q20': getStrVal('q20'),
        'q21': getStrVal('q21'),
        'q22': getStrVal('q22'),
        'q23': getStrVal('q23'),
        'q24': getStrVal('q24'),
        'q25': getStrVal('q25'),
        'q26': getStrVal('q26'),
        'q27': getStrVal('q27'),
        'q28': getStrVal('q28'),
        'q29': getStrVal('q29'),
        'q30': getStrVal('q30'),
        'q31': getStrVal('q31'),
        'q32': getStrVal('q32'),
        'q33': getStrVal('q33'),
        'q34': getStrVal('q34'),
        'q35': getStrVal('q35'),
        'q36': getStrVal('q36'),
        'q37': getStrVal('q37'),
        'q38': getStrVal('q38'),
        'q39': getStrVal('q39'),
        'q40': getStrVal('q40'),

        ///GRADING COMMENTS
        'qa_comment': getStrVal('qa_comment'),
        'qb_comment': getStrVal('qb_comment'),
        'qc_comment': getStrVal('qc_comment'),
        'qd_comment': getStrVal('qd_comment'),
        'qe_comment': getStrVal('qe_comment'),
        'qf_comment': getStrVal('qf_comment'),
        'qg_comment': getStrVal('qg_comment'),

        ///Additional Comment
        'additional_comment': getStrVal('additional_comment'),

        ///RESULT
        'result': getStrVal('result'),
        'evaluator_result': getStrVal('evaluator_result'),
        'trainee_sig_date': getStrVal('trainee_sig_date'),
        'purser_sig_date': getStrVal('purser_sig_date'),
        'evaluator_sig_date': getStrVal('evaluator_sig_date'),
      };
    } else if (type == FormType.psc) {
      return {
        ///----------------------------------------------------------------------
        ///HEADER
        ///----------------------------------------------------------------------
        ///Form info.
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

        ///----------------------------------------------------------------------
        ///ITEM
        ///----------------------------------------------------------------------
        ///Trainee info.
        'trainee_name': getStrVal('trainee_name'),
        'trainee_id': getStrVal('trainee_id'),

        ///Purser info.
        'purser_name': getStrVal('purser_name'),
        'purser_id': getStrVal('purser_id'),

        ///Evaluator
        'evaluator_name': getStrVal('evaluator_name'),
        'evaluator_id': getStrVal('evaluator_id'),

        ///Flight details
        'check_date': getStrVal('check_date'),
        'check_course': getStrVal('check_course'),
        'check_type': getStrVal('check_type'),
        'position': getStrVal('position'),
        'ac_type': getStrVal('ac_type'),
        'ac_reg': getStrVal('ac_reg'),
        'flight': getStrVal('flight'),
        'route': getStrVal('route'),

        ///Grading & Comment
        'q1': getStrVal('q1'),
        'q2': getStrVal('q2'),
        'q3': getStrVal('q3'),
        'q4': getStrVal('q4'),
        'q5': getStrVal('q5'),
        'q6': getStrVal('q6'),
        'q7': getStrVal('q7'),
        'q8': getStrVal('q8'),
        'q9': getStrVal('q9'),
        'q10': getStrVal('q10'),
        'q11': getStrVal('q11'),
        'q12': getStrVal('q12'),
        'q13': getStrVal('q13'),
        'q14': getStrVal('q14'),
        'q15': getStrVal('q15'),
        'q16': getStrVal('q16'),
        'q17': getStrVal('q17'),
        'q18': getStrVal('q18'),
        'q19': getStrVal('q19'),
        'q20': getStrVal('q20'),
        'q21': getStrVal('q21'),
        'q22': getStrVal('q22'),
        'q23': getStrVal('q23'),
        'q24': getStrVal('q24'),
        'q25': getStrVal('q25'),
        'q26': getStrVal('q26'),
        'q27': getStrVal('q27'),
        'q28': getStrVal('q28'),
        'q29': getStrVal('q29'),
        'q30': getStrVal('q30'),
        'q31': getStrVal('q31'),
        'q32': getStrVal('q32'),
        'q33': getStrVal('q33'),
        'q34': getStrVal('q34'),
        'q35': getStrVal('q35'),
        'q36': getStrVal('q36'),
        'q37': getStrVal('q37'),
        'q38': getStrVal('q38'),
        'q39': getStrVal('q39'),
        'q40': getStrVal('q40'),
        'q41': getStrVal('q41'),
        'q42': getStrVal('q42'),
        'q43': getStrVal('q43'),
        'q44': getStrVal('q44'),
        'q45': getStrVal('q45'),
        'q46': getStrVal('q46'),
        'q47': getStrVal('q47'),
        'q48': getStrVal('q48'),
        'q49': getStrVal('q49'),
        'q50': getStrVal('q50'),
        'q51': getStrVal('q51'),
        'q52': getStrVal('q52'),
        'q53': getStrVal('q53'),
        'q54': getStrVal('q54'),
        'q55': getStrVal('q55'),
        'q56': getStrVal('q56'),
        'q57': getStrVal('q57'),
        'q58': getStrVal('q58'),
        'q59': getStrVal('q59'),
        'q60': getStrVal('q60'),
        'q61': getStrVal('q61'),
        'q62': getStrVal('q62'),
        'q63': getStrVal('q63'),
        'q64': getStrVal('q64'),
        'q65': getStrVal('q65'),
        'q66': getStrVal('q66'),
        'q67': getStrVal('q67'),
        'q68': getStrVal('q68'),
        'q69': getStrVal('q69'),
        'q70': getStrVal('q70'),
        'q71': getStrVal('q71'),
        'q72': getStrVal('q72'),
        'q73': getStrVal('q73'),
        'q74': getStrVal('q74'),
        'q75': getStrVal('q75'),
        'q76': getStrVal('q76'),
        'q77': getStrVal('q77'),
        'q78': getStrVal('q78'),
        'q79': getStrVal('q79'),
        'q80': getStrVal('q80'),
        'q81': getStrVal('q81'),
        'q82': getStrVal('q82'),
        'q83': getStrVal('q83'),
        'q84': getStrVal('q84'),
        'q85': getStrVal('q85'),
        'q86': getStrVal('q86'),
        'q87': getStrVal('q87'),
        'q88': getStrVal('q88'),
        'q89': getStrVal('q89'),
        'q90': getStrVal('q90'),
        'q91': getStrVal('q91'),
        'q92': getStrVal('q92'),
        'q93': getStrVal('q93'),

        ///GRADING COMMENTS
        'qa_comment': getStrVal('qa_comment'),
        'qb_comment': getStrVal('qb_comment'),
        'qc_comment': getStrVal('qc_comment'),
        'qd_comment': getStrVal('qd_comment'),
        'qe_comment': getStrVal('qe_comment'),
        'qf_comment': getStrVal('qf_comment'),
        'qg_comment': getStrVal('qg_comment'),
        'qh_comment': getStrVal('qh_comment'),
        'qi_comment': getStrVal('qi_comment'),
        'qj_comment': getStrVal('qj_comment'),

        ///Additional Comment
        'additional_comment': getStrVal('additional_comment'),

        ///RESULT
        'result': getStrVal('result'),
        'evaluator_result': getStrVal('evaluator_result'),
        'trainee_sig_date': getStrVal('trainee_sig_date'),
        'purser_sig_date': getStrVal('purser_sig_date'),
        'evaluator_sig_date': getStrVal('evaluator_sig_date'),
      };
    } else {
      return ({});
    }

    ///BACKUP OLD LOGIC
    // if (type == FormType.lineCheck) {
    //   return {
    //     //----------------------------------------------------------------------
    //     //HEADER
    //     //----------------------------------------------------------------------
    //     //Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //     //----------------------------------------------------------------------
    //     //ITEM
    //     //----------------------------------------------------------------------
    //     //Pilot info.
    //     'pilot_rank': fields[fields.indexWhere((e) => e.name == 'pilot_rank')]
    //         .stringValue,
    //     'pilot_id':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
    //     'pilot_license_no':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
    //             .stringValue,
    //     'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
    //         .stringValue,
    //
    //     //Examiner info.
    //     'examiner_rank':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_rank')]
    //             .stringValue,
    //     'examiner_id': fields[fields.indexWhere((e) => e.name == 'examiner_id')]
    //         .stringValue,
    //     'examiner_license_no':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_license_no')]
    //             .stringValue,
    //     'examiner_name':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_name')]
    //             .stringValue,
    //
    //     //Check type
    //     'type_of_check':
    //         fields[fields.indexWhere((e) => e.name == 'type_of_check')]
    //             .stringValue,
    //     'other_type': fields[fields.indexWhere((e) => e.name == 'other_type')]
    //         .stringValue,
    //
    //     //Sector#1
    //     'date_1':
    //         fields[fields.indexWhere((e) => e.name == 'date_1')].stringValue,
    //     'ac_type_1':
    //         fields[fields.indexWhere((e) => e.name == 'ac_type_1')].stringValue,
    //     'ac_reg_1':
    //         fields[fields.indexWhere((e) => e.name == 'ac_reg_1')].stringValue,
    //     'flt_no_1':
    //         fields[fields.indexWhere((e) => e.name == 'flt_no_1')].stringValue,
    //     'from_1':
    //         fields[fields.indexWhere((e) => e.name == 'from_1')].stringValue,
    //     'to_1': fields[fields.indexWhere((e) => e.name == 'to_1')].stringValue,
    //     'duty_1':
    //         fields[fields.indexWhere((e) => e.name == 'duty_1')].stringValue,
    //
    //     //Sector#2
    //     'date_2':
    //         fields[fields.indexWhere((e) => e.name == 'date_2')].stringValue,
    //     'ac_type_2':
    //         fields[fields.indexWhere((e) => e.name == 'ac_type_2')].stringValue,
    //     'ac_reg_2':
    //         fields[fields.indexWhere((e) => e.name == 'ac_reg_2')].stringValue,
    //     'flt_no_2':
    //         fields[fields.indexWhere((e) => e.name == 'flt_no_2')].stringValue,
    //     'from_2':
    //         fields[fields.indexWhere((e) => e.name == 'from_2')].stringValue,
    //     'to_2': fields[fields.indexWhere((e) => e.name == 'to_2')].stringValue,
    //     'duty_2':
    //         fields[fields.indexWhere((e) => e.name == 'duty_2')].stringValue,
    //
    //     //Grading & Comment
    //     //A
    //     'a_1': fields[fields.indexWhere((e) => e.name == 'a_1')].stringValue,
    //     'a_2': fields[fields.indexWhere((e) => e.name == 'a_2')].stringValue,
    //     'a_3': fields[fields.indexWhere((e) => e.name == 'a_3')].stringValue,
    //     'a_4': fields[fields.indexWhere((e) => e.name == 'a_4')].stringValue,
    //     'a_5': fields[fields.indexWhere((e) => e.name == 'a_5')].stringValue,
    //     'a_6': fields[fields.indexWhere((e) => e.name == 'a_6')].stringValue,
    //     'a_7': fields[fields.indexWhere((e) => e.name == 'a_7')].stringValue,
    //     'a_comment':
    //         fields[fields.indexWhere((e) => e.name == 'a_comment')].stringValue,
    //     //B
    //     'b_8': fields[fields.indexWhere((e) => e.name == 'b_8')].stringValue,
    //     'b_9': fields[fields.indexWhere((e) => e.name == 'b_9')].stringValue,
    //     'b_10': fields[fields.indexWhere((e) => e.name == 'b_10')].stringValue,
    //     'b_11': fields[fields.indexWhere((e) => e.name == 'b_11')].stringValue,
    //     'b_12': fields[fields.indexWhere((e) => e.name == 'b_12')].stringValue,
    //     'b_13': fields[fields.indexWhere((e) => e.name == 'b_13')].stringValue,
    //     'b_comment':
    //         fields[fields.indexWhere((e) => e.name == 'b_comment')].stringValue,
    //     //C
    //     'c_14': fields[fields.indexWhere((e) => e.name == 'c_14')].stringValue,
    //     'c_15': fields[fields.indexWhere((e) => e.name == 'c_15')].stringValue,
    //     'c_16': fields[fields.indexWhere((e) => e.name == 'c_16')].stringValue,
    //     'c_17': fields[fields.indexWhere((e) => e.name == 'c_17')].stringValue,
    //     'c_18': fields[fields.indexWhere((e) => e.name == 'c_18')].stringValue,
    //     'c_comment':
    //         fields[fields.indexWhere((e) => e.name == 'c_comment')].stringValue,
    //     //D
    //     'd_19': fields[fields.indexWhere((e) => e.name == 'd_19')].stringValue,
    //     'd_20': fields[fields.indexWhere((e) => e.name == 'd_20')].stringValue,
    //     'd_21': fields[fields.indexWhere((e) => e.name == 'd_21')].stringValue,
    //     'd_22': fields[fields.indexWhere((e) => e.name == 'd_22')].stringValue,
    //     'd_23': fields[fields.indexWhere((e) => e.name == 'd_23')].stringValue,
    //     'd_24': fields[fields.indexWhere((e) => e.name == 'd_24')].stringValue,
    //     'd_25': fields[fields.indexWhere((e) => e.name == 'd_25')].stringValue,
    //     'd_26': fields[fields.indexWhere((e) => e.name == 'd_26')].stringValue,
    //     'd_27': fields[fields.indexWhere((e) => e.name == 'd_27')].stringValue,
    //     'd_28': fields[fields.indexWhere((e) => e.name == 'd_28')].stringValue,
    //     'd_comment':
    //         fields[fields.indexWhere((e) => e.name == 'd_comment')].stringValue,
    //     //E
    //     'e_29': fields[fields.indexWhere((e) => e.name == 'e_29')].stringValue,
    //     'e_30': fields[fields.indexWhere((e) => e.name == 'e_30')].stringValue,
    //     'e_31': fields[fields.indexWhere((e) => e.name == 'e_31')].stringValue,
    //     'e_32': fields[fields.indexWhere((e) => e.name == 'e_32')].stringValue,
    //     'e_33': fields[fields.indexWhere((e) => e.name == 'e_33')].stringValue,
    //     'e_34': fields[fields.indexWhere((e) => e.name == 'e_34')].stringValue,
    //     'e_comment':
    //         fields[fields.indexWhere((e) => e.name == 'e_comment')].stringValue,
    //     //BRIEFING
    //     'brief_1':
    //         fields[fields.indexWhere((e) => e.name == 'brief_1')].stringValue,
    //     'brief_2':
    //         fields[fields.indexWhere((e) => e.name == 'brief_2')].stringValue,
    //     'brief_3':
    //         fields[fields.indexWhere((e) => e.name == 'brief_3')].stringValue,
    //     'brief_4':
    //         fields[fields.indexWhere((e) => e.name == 'brief_4')].stringValue,
    //     'brief_5':
    //         fields[fields.indexWhere((e) => e.name == 'brief_5')].stringValue,
    //     'brief_comment':
    //         fields[fields.indexWhere((e) => e.name == 'brief_comment')]
    //             .stringValue,
    //     //COMPETENCY
    //     'comp_pro':
    //         fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
    //     'comp_com':
    //         fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
    //     'comp_fpa':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
    //     'comp_fpm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
    //     'comp_kno':
    //         fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
    //     'comp_ltw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
    //     'comp_psd':
    //         fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
    //     'comp_saw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
    //     'comp_wlm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
    //     'general_comment':
    //         fields[fields.indexWhere((e) => e.name == 'general_comment')]
    //             .stringValue,
    //     //RESULT
    //     'result':
    //         fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //     'competent_level':
    //         fields[fields.indexWhere((e) => e.name == 'competent_level')]
    //             .stringValue,
    //     'result_comment':
    //         fields[fields.indexWhere((e) => e.name == 'result_comment')]
    //             .stringValue,
    //
    //     'pilot_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
    //             .stringValue,
    //     'examiner_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_sig_date')]
    //             .stringValue,
    //   };
    // } else if (type == FormType.ppc) {
    //   return {
    //     //----------------------------------------------------------------------
    //     //HEADER
    //     //----------------------------------------------------------------------
    //     //Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //     //----------------------------------------------------------------------
    //     //ITEM
    //     //----------------------------------------------------------------------
    //     //Pilot info.
    //     'pilot_rank': fields[fields.indexWhere((e) => e.name == 'pilot_rank')]
    //         .stringValue,
    //     'pilot_id':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
    //     'pilot_license_no':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
    //             .stringValue,
    //     'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
    //         .stringValue,
    //
    //     //Instructor info.
    //     'instructor_rank':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_rank')]
    //             .stringValue,
    //     'instructor_id':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_id')]
    //             .stringValue,
    //     'instructor_cert_no':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_cert_no')]
    //             .stringValue,
    //     'instructor_name':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_name')]
    //             .stringValue,
    //
    //     //Examiner info.
    //     'examiner_type':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_type')]
    //             .stringValue,
    //     'examiner_id': fields[fields.indexWhere((e) => e.name == 'examiner_id')]
    //         .stringValue,
    //     'examiner_pel_no':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_pel_no')]
    //             .stringValue,
    //     'examiner_name':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_name')]
    //             .stringValue,
    //
    //     //Check details
    //     'check_date': fields[fields.indexWhere((e) => e.name == 'check_date')]
    //         .stringValue,
    //     'block_time': fields[fields.indexWhere((e) => e.name == 'block_time')]
    //         .stringValue,
    //     'fstd_no':
    //         fields[fields.indexWhere((e) => e.name == 'fstd_no')].stringValue,
    //     'route':
    //         fields[fields.indexWhere((e) => e.name == 'route')].stringValue,
    //     'check_course':
    //         fields[fields.indexWhere((e) => e.name == 'check_course')]
    //             .stringValue,
    //     // 'check_type': fields[fields.indexWhere((e) => e.name == 'check_type')]
    //     //     .stringValue,
    //     'check_type_0':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_0')]
    //             .stringValue,
    //     'check_type_1':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_1')]
    //             .stringValue,
    //     'check_type_2':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_2')]
    //             .stringValue,
    //
    //     //Grading & Comment
    //     //A
    //     'a_1': fields[fields.indexWhere((e) => e.name == 'a_1')].stringValue,
    //     'a_2_detail': fields[fields.indexWhere((e) => e.name == 'a_2_detail')]
    //         .stringValue,
    //     'a_2': fields[fields.indexWhere((e) => e.name == 'a_2')].stringValue,
    //     'a_3': fields[fields.indexWhere((e) => e.name == 'a_3')].stringValue,
    //     'a_comment':
    //         fields[fields.indexWhere((e) => e.name == 'a_comment')].stringValue,
    //     //B
    //     'b_4': fields[fields.indexWhere((e) => e.name == 'b_4')].stringValue,
    //     'b_5': fields[fields.indexWhere((e) => e.name == 'b_5')].stringValue,
    //     'b_6': fields[fields.indexWhere((e) => e.name == 'b_6')].stringValue,
    //     'b_7': fields[fields.indexWhere((e) => e.name == 'b_7')].stringValue,
    //     'b_8': fields[fields.indexWhere((e) => e.name == 'b_8')].stringValue,
    //     'b_comment':
    //         fields[fields.indexWhere((e) => e.name == 'b_comment')].stringValue,
    //     //C
    //     'c_9': fields[fields.indexWhere((e) => e.name == 'c_9')].stringValue,
    //     'c_10': fields[fields.indexWhere((e) => e.name == 'c_10')].stringValue,
    //     'c_11': fields[fields.indexWhere((e) => e.name == 'c_11')].stringValue,
    //     'c_12': fields[fields.indexWhere((e) => e.name == 'c_12')].stringValue,
    //     // 'c_13_detail': fields[fields.indexWhere((e) => e.name == 'c_13_detail')]
    //     //     .stringValue,
    //     'c_13_check_0':
    //         fields[fields.indexWhere((e) => e.name == 'c_13_check_0')]
    //             .stringValue,
    //     'c_13_check_1':
    //         fields[fields.indexWhere((e) => e.name == 'c_13_check_1')]
    //             .stringValue,
    //     'c_13_check_2':
    //         fields[fields.indexWhere((e) => e.name == 'c_13_check_2')]
    //             .stringValue,
    //     'c_13': fields[fields.indexWhere((e) => e.name == 'c_13')].stringValue,
    //     'c_14': fields[fields.indexWhere((e) => e.name == 'c_14')].stringValue,
    //     'c_15': fields[fields.indexWhere((e) => e.name == 'c_15')].stringValue,
    //     'c_16': fields[fields.indexWhere((e) => e.name == 'c_16')].stringValue,
    //     'c_comment':
    //         fields[fields.indexWhere((e) => e.name == 'c_comment')].stringValue,
    //     //D
    //     'd_17': fields[fields.indexWhere((e) => e.name == 'd_17')].stringValue,
    //     // 'd_18_check': fields[fields.indexWhere((e) => e.name == 'd_18_check')]
    //     //     .stringValue,
    //     'd_18_check_0':
    //         fields[fields.indexWhere((e) => e.name == 'd_18_check_0')]
    //             .stringValue,
    //     'd_18_check_1':
    //         fields[fields.indexWhere((e) => e.name == 'd_18_check_1')]
    //             .stringValue,
    //     'd_18': fields[fields.indexWhere((e) => e.name == 'd_18')].stringValue,
    //     'd_19': fields[fields.indexWhere((e) => e.name == 'd_19')].stringValue,
    //     'd_comment':
    //         fields[fields.indexWhere((e) => e.name == 'd_comment')].stringValue,
    //     //E
    //     // 'e_20_check': fields[fields.indexWhere((e) => e.name == 'e_20_check')]
    //     //     .stringValue,
    //     'e_20_check_0':
    //         fields[fields.indexWhere((e) => e.name == 'e_20_check_0')]
    //             .stringValue,
    //     'e_20_check_1':
    //         fields[fields.indexWhere((e) => e.name == 'e_20_check_1')]
    //             .stringValue,
    //     'e_20': fields[fields.indexWhere((e) => e.name == 'e_20')].stringValue,
    //     'e_21': fields[fields.indexWhere((e) => e.name == 'e_21')].stringValue,
    //     'e_22': fields[fields.indexWhere((e) => e.name == 'e_22')].stringValue,
    //     'e_23': fields[fields.indexWhere((e) => e.name == 'e_23')].stringValue,
    //     'e_24': fields[fields.indexWhere((e) => e.name == 'e_24')].stringValue,
    //     'e_25': fields[fields.indexWhere((e) => e.name == 'e_25')].stringValue,
    //     'e_comment':
    //         fields[fields.indexWhere((e) => e.name == 'e_comment')].stringValue,
    //     //F
    //     'f_26': fields[fields.indexWhere((e) => e.name == 'f_26')].stringValue,
    //     'f_27': fields[fields.indexWhere((e) => e.name == 'f_27')].stringValue,
    //     'f_comment':
    //         fields[fields.indexWhere((e) => e.name == 'f_comment')].stringValue,
    //     //G
    //     // 'g_28_check': fields[fields.indexWhere((e) => e.name == 'g_28_check')]
    //     //     .stringValue,
    //     'g_28_check_0':
    //         fields[fields.indexWhere((e) => e.name == 'g_28_check_0')]
    //             .stringValue,
    //     'g_28_check_1':
    //         fields[fields.indexWhere((e) => e.name == 'g_28_check_1')]
    //             .stringValue,
    //     'g_28_check_2':
    //         fields[fields.indexWhere((e) => e.name == 'g_28_check_2')]
    //             .stringValue,
    //     'g_28_check_3':
    //         fields[fields.indexWhere((e) => e.name == 'g_28_check_3')]
    //             .stringValue,
    //     'g_28_check_4':
    //         fields[fields.indexWhere((e) => e.name == 'g_28_check_4')]
    //             .stringValue,
    //     'g_28': fields[fields.indexWhere((e) => e.name == 'g_28')].stringValue,
    //     'g_29': fields[fields.indexWhere((e) => e.name == 'g_29')].stringValue,
    //     'g_30': fields[fields.indexWhere((e) => e.name == 'g_30')].stringValue,
    //     'g_31': fields[fields.indexWhere((e) => e.name == 'g_31')].stringValue,
    //     'g_32': fields[fields.indexWhere((e) => e.name == 'g_32')].stringValue,
    //     'g_comment':
    //         fields[fields.indexWhere((e) => e.name == 'g_comment')].stringValue,
    //     //H
    //     'h_33': fields[fields.indexWhere((e) => e.name == 'h_33')].stringValue,
    //     'h_34': fields[fields.indexWhere((e) => e.name == 'h_34')].stringValue,
    //     'h_35': fields[fields.indexWhere((e) => e.name == 'h_35')].stringValue,
    //     'h_36': fields[fields.indexWhere((e) => e.name == 'h_36')].stringValue,
    //     'h_comment':
    //         fields[fields.indexWhere((e) => e.name == 'h_comment')].stringValue,
    //     //I
    //     'i_37': fields[fields.indexWhere((e) => e.name == 'i_37')].stringValue,
    //     'i_38': fields[fields.indexWhere((e) => e.name == 'i_38')].stringValue,
    //     'i_39': fields[fields.indexWhere((e) => e.name == 'i_39')].stringValue,
    //     'i_40': fields[fields.indexWhere((e) => e.name == 'i_40')].stringValue,
    //     'i_41': fields[fields.indexWhere((e) => e.name == 'i_41')].stringValue,
    //     'i_comment':
    //         fields[fields.indexWhere((e) => e.name == 'i_comment')].stringValue,
    //     //J
    //     'j_42': fields[fields.indexWhere((e) => e.name == 'j_42')].stringValue,
    //     'j_43': fields[fields.indexWhere((e) => e.name == 'j_43')].stringValue,
    //     'j_44_detail': fields[fields.indexWhere((e) => e.name == 'j_44_detail')]
    //         .stringValue,
    //     'j_44': fields[fields.indexWhere((e) => e.name == 'j_44')].stringValue,
    //     'j_45_detail': fields[fields.indexWhere((e) => e.name == 'j_45_detail')]
    //         .stringValue,
    //     'j_45': fields[fields.indexWhere((e) => e.name == 'j_45')].stringValue,
    //     'j_46_detail': fields[fields.indexWhere((e) => e.name == 'j_46_detail')]
    //         .stringValue,
    //     'j_46': fields[fields.indexWhere((e) => e.name == 'j_46')].stringValue,
    //     'j_47_detail': fields[fields.indexWhere((e) => e.name == 'j_47_detail')]
    //         .stringValue,
    //     'j_47': fields[fields.indexWhere((e) => e.name == 'j_47')].stringValue,
    //     'j_48_detail': fields[fields.indexWhere((e) => e.name == 'j_48_detail')]
    //         .stringValue,
    //     'j_48': fields[fields.indexWhere((e) => e.name == 'j_48')].stringValue,
    //     'j_comment':
    //         fields[fields.indexWhere((e) => e.name == 'j_comment')].stringValue,
    //     //LANDING AND GO-AROUND
    //     'no_landing': fields[fields.indexWhere((e) => e.name == 'no_landing')]
    //         .stringValue,
    //     'no_goaround': fields[fields.indexWhere((e) => e.name == 'no_goaround')]
    //         .stringValue,
    //
    //     //COMPETENCY
    //     'comp_kno':
    //         fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
    //     'comp_pro':
    //         fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
    //     'comp_com':
    //         fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
    //     'comp_fpa':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
    //     'comp_fpm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
    //     'comp_ltw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
    //     'comp_psd':
    //         fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
    //     'comp_saw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
    //     'comp_wlm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
    //     'general_comment':
    //         fields[fields.indexWhere((e) => e.name == 'general_comment')]
    //             .stringValue,
    //     //RESULT
    //     'result':
    //         fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //
    //     'pilot_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
    //             .stringValue,
    //     'examiner_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_sig_date')]
    //             .stringValue,
    //   };
    // } else if (type == FormType.ppc5) {
    //   return {
    //     ///----------------------------------------------------------------------
    //     ///HEADER
    //     ///----------------------------------------------------------------------
    //     ///Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //     ///----------------------------------------------------------------------
    //     ///ITEM
    //     ///----------------------------------------------------------------------
    //     ///Pilot info.
    //     'pilot_rank': fields[fields.indexWhere((e) => e.name == 'pilot_rank')]
    //         .stringValue,
    //     'pilot_id':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
    //     'pilot_license_no':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
    //         .stringValue,
    //     'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
    //         .stringValue,
    //
    //     //Instructor info.
    //     'instructor_rank':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_rank')]
    //         .stringValue,
    //     'instructor_id':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_id')]
    //         .stringValue,
    //     'instructor_cert_no':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_cert_no')]
    //         .stringValue,
    //     'instructor_name':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_name')]
    //         .stringValue,
    //
    //     ///Examiner info.
    //     'examiner_type':
    //     fields[fields.indexWhere((e) => e.name == 'examiner_type')]
    //         .stringValue,
    //     'examiner_id': fields[fields.indexWhere((e) => e.name == 'examiner_id')]
    //         .stringValue,
    //     'examiner_pel_no':
    //     fields[fields.indexWhere((e) => e.name == 'examiner_pel_no')]
    //         .stringValue,
    //     'examiner_name':
    //     fields[fields.indexWhere((e) => e.name == 'examiner_name')]
    //         .stringValue,
    //
    //     ///Check details
    //     'check_date': fields[fields.indexWhere((e) => e.name == 'check_date')]
    //         .stringValue,
    //     'block_time': fields[fields.indexWhere((e) => e.name == 'block_time')]
    //         .stringValue,
    //     'fstd_no':
    //     fields[fields.indexWhere((e) => e.name == 'fstd_no')].stringValue,
    //     'route':
    //     fields[fields.indexWhere((e) => e.name == 'route')].stringValue,
    //     'check_type_0':
    //     fields[fields.indexWhere((e) => e.name == 'check_type_0')]
    //         .stringValue,
    //     'check_type_1':
    //     fields[fields.indexWhere((e) => e.name == 'check_type_1')]
    //         .stringValue,
    //     'check_type_2':
    //     fields[fields.indexWhere((e) => e.name == 'check_type_2')]
    //         .stringValue,
    //     'check_type_3':
    //     fields[fields.indexWhere((e) => e.name == 'check_type_3')]
    //         .stringValue,
    //
    //     ///Grading & Comment
    //     ///A
    //     'q1': fields[fields.indexWhere((e) => e.name == 'q1')].stringValue,
    //     'q2_detail': fields[fields.indexWhere((e) => e.name == 'q2_detail')].stringValue,
    //     'q2': fields[fields.indexWhere((e) => e.name == 'q2')].stringValue,
    //     'q3': fields[fields.indexWhere((e) => e.name == 'q3')].stringValue,
    //     'qa_comment': fields[fields.indexWhere((e) => e.name == 'qa_comment')]
    //         .stringValue,
    //
    //     ///B
    //     'q4': fields[fields.indexWhere((e) => e.name == 'q4')].stringValue,
    //     'q5': fields[fields.indexWhere((e) => e.name == 'q5')].stringValue,
    //     'q6': fields[fields.indexWhere((e) => e.name == 'q6')].stringValue,
    //     'q7': fields[fields.indexWhere((e) => e.name == 'q7')].stringValue,
    //     'qb_comment': fields[fields.indexWhere((e) => e.name == 'qb_comment')]
    //         .stringValue,
    //
    //     ///C
    //     'q8': fields[fields.indexWhere((e) => e.name == 'q8')].stringValue,
    //     'q9': fields[fields.indexWhere((e) => e.name == 'q9')].stringValue,
    //     'q10': fields[fields.indexWhere((e) => e.name == 'q10')].stringValue,
    //     'q11_check_0': fields[fields.indexWhere((e) => e.name == 'q11_check_0')]
    //         .stringValue,
    //     'q11_check_1': fields[fields.indexWhere((e) => e.name == 'q11_check_1')]
    //         .stringValue,
    //     'q11': fields[fields.indexWhere((e) => e.name == 'q11')].stringValue,
    //     'q12': fields[fields.indexWhere((e) => e.name == 'q12')].stringValue,
    //     'q13_check_0': fields[fields.indexWhere((e) => e.name == 'q13_check_0')]
    //         .stringValue,
    //     'q13_check_1': fields[fields.indexWhere((e) => e.name == 'q13_check_1')]
    //         .stringValue,
    //     'q13_check_2': fields[fields.indexWhere((e) => e.name == 'q13_check_2')]
    //         .stringValue,
    //     'q13': fields[fields.indexWhere((e) => e.name == 'q13')].stringValue,
    //     'q14': fields[fields.indexWhere((e) => e.name == 'q14')].stringValue,
    //     'q15': fields[fields.indexWhere((e) => e.name == 'q15')].stringValue,
    //     'q16_check_0': fields[fields.indexWhere((e) => e.name == 'q16_check_0')]
    //         .stringValue,
    //     'q16_check_1': fields[fields.indexWhere((e) => e.name == 'q16_check_1')]
    //         .stringValue,
    //     'q16': fields[fields.indexWhere((e) => e.name == 'q16')].stringValue,
    //     'q17': fields[fields.indexWhere((e) => e.name == 'q17')].stringValue,
    //     'q18': fields[fields.indexWhere((e) => e.name == 'q18')].stringValue,
    //     'qc_comment': fields[fields.indexWhere((e) => e.name == 'qc_comment')]
    //         .stringValue,
    //
    //     ///D
    //     'q19': fields[fields.indexWhere((e) => e.name == 'q19')].stringValue,
    //     'q20': fields[fields.indexWhere((e) => e.name == 'q20')].stringValue,
    //     'q21': fields[fields.indexWhere((e) => e.name == 'q21')].stringValue,
    //     'q22': fields[fields.indexWhere((e) => e.name == 'q22')].stringValue,
    //     'q23': fields[fields.indexWhere((e) => e.name == 'q23')].stringValue,
    //     'q24': fields[fields.indexWhere((e) => e.name == 'q24')].stringValue,
    //     'q25': fields[fields.indexWhere((e) => e.name == 'q25')].stringValue,
    //     'q26': fields[fields.indexWhere((e) => e.name == 'q26')].stringValue,
    //     'q27': fields[fields.indexWhere((e) => e.name == 'q27')].stringValue,
    //     'q28': fields[fields.indexWhere((e) => e.name == 'q28')].stringValue,
    //     'q29': fields[fields.indexWhere((e) => e.name == 'q29')].stringValue,
    //     'q30': fields[fields.indexWhere((e) => e.name == 'q30')].stringValue,
    //     'qd_comment': fields[fields.indexWhere((e) => e.name == 'qd_comment')]
    //         .stringValue,
    //
    //     ///E
    //     'q31': fields[fields.indexWhere((e) => e.name == 'q31')].stringValue,
    //     'q32': fields[fields.indexWhere((e) => e.name == 'q32')].stringValue,
    //     'q33': fields[fields.indexWhere((e) => e.name == 'q33')].stringValue,
    //     'q34': fields[fields.indexWhere((e) => e.name == 'q34')].stringValue,
    //     'q35': fields[fields.indexWhere((e) => e.name == 'q35')].stringValue,
    //     'q36': fields[fields.indexWhere((e) => e.name == 'q36')].stringValue,
    //     'q37': fields[fields.indexWhere((e) => e.name == 'q37')].stringValue,
    //     'qe_comment': fields[fields.indexWhere((e) => e.name == 'qe_comment')]
    //         .stringValue,
    //
    //     ///F
    //     'q38': fields[fields.indexWhere((e) => e.name == 'q38')].stringValue,
    //     'q39': fields[fields.indexWhere((e) => e.name == 'q39')].stringValue,
    //     'q40': fields[fields.indexWhere((e) => e.name == 'q40')].stringValue,
    //     'qf_comment': fields[fields.indexWhere((e) => e.name == 'qf_comment')]
    //         .stringValue,
    //
    //     ///G
    //     'q41': fields[fields.indexWhere((e) => e.name == 'q41')].stringValue,
    //     'q42': fields[fields.indexWhere((e) => e.name == 'q42')].stringValue,
    //     'q43': fields[fields.indexWhere((e) => e.name == 'q43')].stringValue,
    //     'q44': fields[fields.indexWhere((e) => e.name == 'q44')].stringValue,
    //     'q45': fields[fields.indexWhere((e) => e.name == 'q45')].stringValue,
    //     'q46': fields[fields.indexWhere((e) => e.name == 'q46')].stringValue,
    //     'q47': fields[fields.indexWhere((e) => e.name == 'q47')].stringValue,
    //     'qg_comment': fields[fields.indexWhere((e) => e.name == 'qg_comment')]
    //         .stringValue,
    //
    //     ///H
    //     'q48': fields[fields.indexWhere((e) => e.name == 'q48')].stringValue,
    //     'q49': fields[fields.indexWhere((e) => e.name == 'q49')].stringValue,
    //     'q50': fields[fields.indexWhere((e) => e.name == 'q50')].stringValue,
    //     'qh_comment': fields[fields.indexWhere((e) => e.name == 'qh_comment')]
    //         .stringValue,
    //
    //     ///I
    //     'q51': fields[fields.indexWhere((e) => e.name == 'q51')].stringValue,
    //     'q52': fields[fields.indexWhere((e) => e.name == 'q52')].stringValue,
    //     'q53': fields[fields.indexWhere((e) => e.name == 'q53')].stringValue,
    //     'qi_comment': fields[fields.indexWhere((e) => e.name == 'qi_comment')]
    //         .stringValue,
    //
    //     ///J
    //     'q54_detail': fields[fields.indexWhere((e) => e.name == 'q54_detail')].stringValue,
    //     'q54': fields[fields.indexWhere((e) => e.name == 'q54')].stringValue,
    //     'q55_detail': fields[fields.indexWhere((e) => e.name == 'q55_detail')].stringValue,
    //     'q55': fields[fields.indexWhere((e) => e.name == 'q55')].stringValue,
    //     'q56_detail': fields[fields.indexWhere((e) => e.name == 'q56_detail')].stringValue,
    //     'q56': fields[fields.indexWhere((e) => e.name == 'q56')].stringValue,
    //     'q57_detail': fields[fields.indexWhere((e) => e.name == 'q57_detail')].stringValue,
    //     'q57': fields[fields.indexWhere((e) => e.name == 'q57')].stringValue,
    //     'q58_detail': fields[fields.indexWhere((e) => e.name == 'q58_detail')].stringValue,
    //     'q58': fields[fields.indexWhere((e) => e.name == 'q58')].stringValue,
    //     'qj_comment': fields[fields.indexWhere((e) => e.name == 'qj_comment')]
    //         .stringValue,
    //
    //     ///LANDING AND GO-AROUND
    //     'no_landing': fields[fields.indexWhere((e) => e.name == 'no_landing')]
    //         .stringValue,
    //     'no_goaround': fields[fields.indexWhere((e) => e.name == 'no_goaround')]
    //         .stringValue,
    //
    //     ///COMPETENCY
    //     'comp_kno':
    //     fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
    //     'comp_pro':
    //     fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
    //     'comp_com':
    //     fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
    //     'comp_fpa':
    //     fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
    //     'comp_fpm':
    //     fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
    //     'comp_ltw':
    //     fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
    //     'comp_psd':
    //     fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
    //     'comp_saw':
    //     fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
    //     'comp_wlm':
    //     fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
    //     'general_comment':
    //     fields[fields.indexWhere((e) => e.name == 'general_comment')]
    //         .stringValue,
    //     //RESULT
    //     'result':
    //     fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //
    //     'pilot_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
    //         .stringValue,
    //     'examiner_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'examiner_sig_date')]
    //         .stringValue,
    //   };
    // } else if (type == FormType.rt1) {
    //   return {
    //     ///----------------------------------------------------------------------
    //     ///HEADER
    //     ///----------------------------------------------------------------------
    //     ///Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //
    //     ///----------------------------------------------------------------------
    //     ///ITEM
    //     ///----------------------------------------------------------------------
    //     ///Pilot info.
    //     'pilot_rank': fields[fields.indexWhere((e) => e.name == 'pilot_rank')]
    //         .stringValue,
    //     'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
    //         .stringValue,
    //     'pilot_license_no':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
    //         .stringValue,
    //     'pilot_id':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
    //
    //     ///Instructor info.
    //     'instructor_rank':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_rank')]
    //         .stringValue,
    //     'instructor_name':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_name')]
    //         .stringValue,
    //     'instructor_cert_no':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_cert_no')]
    //         .stringValue,
    //     'instructor_id':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_id')]
    //         .stringValue,
    //
    //     //Check details
    //     'check_date': fields[fields.indexWhere((e) => e.name == 'check_date')]
    //         .stringValue,
    //     'block_time': fields[fields.indexWhere((e) => e.name == 'block_time')]
    //         .stringValue,
    //     'fstd_no':
    //     fields[fields.indexWhere((e) => e.name == 'fstd_no')].stringValue,
    //     'loft_duty':
    //     fields[fields.indexWhere((e) => e.name == 'loft_duty')].stringValue,
    //
    //     ///Grading & Comment
    //     ///A
    //     'q1': fields[fields.indexWhere((e) => e.name == 'q1')].stringValue,
    //     'q2': fields[fields.indexWhere((e) => e.name == 'q2')].stringValue,
    //     'q3': fields[fields.indexWhere((e) => e.name == 'q3')].stringValue,
    //     'q4': fields[fields.indexWhere((e) => e.name == 'q4')].stringValue,
    //     'qa_comment': fields[fields.indexWhere((e) => e.name == 'qa_comment')]
    //         .stringValue,
    //
    //     ///B
    //     'q5': fields[fields.indexWhere((e) => e.name == 'q5')].stringValue,
    //     'q6_detail': fields[fields.indexWhere((e) => e.name == 'q6_detail')].stringValue,
    //     'q6': fields[fields.indexWhere((e) => e.name == 'q6')].stringValue,
    //     'q7': fields[fields.indexWhere((e) => e.name == 'q7')].stringValue,
    //     'qb_comment': fields[fields.indexWhere((e) => e.name == 'qb_comment')]
    //         .stringValue,
    //
    //     ///C
    //     'q8': fields[fields.indexWhere((e) => e.name == 'q8')].stringValue,
    //     'q9': fields[fields.indexWhere((e) => e.name == 'q9')].stringValue,
    //     'q10': fields[fields.indexWhere((e) => e.name == 'q10')].stringValue,
    //     'q11': fields[fields.indexWhere((e) => e.name == 'q11')].stringValue,
    //     'qc_comment': fields[fields.indexWhere((e) => e.name == 'qc_comment')]
    //         .stringValue,
    //
    //     ///D
    //     'q12': fields[fields.indexWhere((e) => e.name == 'q12')].stringValue,
    //     'q13': fields[fields.indexWhere((e) => e.name == 'q13')].stringValue,
    //     'q14': fields[fields.indexWhere((e) => e.name == 'q14')].stringValue,
    //     'q15': fields[fields.indexWhere((e) => e.name == 'q15')].stringValue,
    //     'q16': fields[fields.indexWhere((e) => e.name == 'q16')].stringValue,
    //     'q17': fields[fields.indexWhere((e) => e.name == 'q17')].stringValue,
    //     'q18': fields[fields.indexWhere((e) => e.name == 'q18')].stringValue,
    //     'q19': fields[fields.indexWhere((e) => e.name == 'q19')].stringValue,
    //     'q20_check_0': fields[fields.indexWhere((e) => e.name == 'q20_check_0')]
    //         .stringValue,
    //     'q20_check_1': fields[fields.indexWhere((e) => e.name == 'q20_check_1')]
    //         .stringValue,
    //     'q20_check_2': fields[fields.indexWhere((e) => e.name == 'q20_check_2')]
    //         .stringValue,
    //     'q20': fields[fields.indexWhere((e) => e.name == 'q20')].stringValue,
    //     'q21_check_0': fields[fields.indexWhere((e) => e.name == 'q21_check_0')]
    //         .stringValue,
    //     'q21_check_1': fields[fields.indexWhere((e) => e.name == 'q21_check_1')]
    //         .stringValue,
    //     'q21': fields[fields.indexWhere((e) => e.name == 'q21')].stringValue,
    //     'q22': fields[fields.indexWhere((e) => e.name == 'q22')].stringValue,
    //     'q23': fields[fields.indexWhere((e) => e.name == 'q23')].stringValue,
    //     'qd_comment': fields[fields.indexWhere((e) => e.name == 'qd_comment')]
    //         .stringValue,
    //
    //     ///E
    //     'q24': fields[fields.indexWhere((e) => e.name == 'q24')].stringValue,
    //     'q25': fields[fields.indexWhere((e) => e.name == 'q25')].stringValue,
    //     'q26': fields[fields.indexWhere((e) => e.name == 'q26')].stringValue,
    //     'qe_comment': fields[fields.indexWhere((e) => e.name == 'qe_comment')]
    //         .stringValue,
    //
    //     ///F
    //     'q27': fields[fields.indexWhere((e) => e.name == 'q27')].stringValue,
    //     'q28': fields[fields.indexWhere((e) => e.name == 'q28')].stringValue,
    //     'q29': fields[fields.indexWhere((e) => e.name == 'q29')].stringValue,
    //     'q30': fields[fields.indexWhere((e) => e.name == 'q30')].stringValue,
    //     'q31': fields[fields.indexWhere((e) => e.name == 'q31')].stringValue,
    //     'q32': fields[fields.indexWhere((e) => e.name == 'q32')].stringValue,
    //     'q33': fields[fields.indexWhere((e) => e.name == 'q33')].stringValue,
    //     'q34': fields[fields.indexWhere((e) => e.name == 'q34')].stringValue,
    //     'q35': fields[fields.indexWhere((e) => e.name == 'q35')].stringValue,
    //     'qf_comment': fields[fields.indexWhere((e) => e.name == 'qf_comment')]
    //         .stringValue,
    //
    //     ///G
    //     'q36': fields[fields.indexWhere((e) => e.name == 'q36')].stringValue,
    //     'q37': fields[fields.indexWhere((e) => e.name == 'q37')].stringValue,
    //     'q38': fields[fields.indexWhere((e) => e.name == 'q38')].stringValue,
    //     'qg_comment': fields[fields.indexWhere((e) => e.name == 'qg_comment')]
    //         .stringValue,
    //
    //     ///H
    //     'q39': fields[fields.indexWhere((e) => e.name == 'q39')].stringValue,
    //     'q40': fields[fields.indexWhere((e) => e.name == 'q40')].stringValue,
    //     'q41': fields[fields.indexWhere((e) => e.name == 'q41')].stringValue,
    //     'q42': fields[fields.indexWhere((e) => e.name == 'q42')].stringValue,
    //     'q43': fields[fields.indexWhere((e) => e.name == 'q43')].stringValue,
    //     'q44': fields[fields.indexWhere((e) => e.name == 'q44')].stringValue,
    //     'qh_comment': fields[fields.indexWhere((e) => e.name == 'qh_comment')]
    //         .stringValue,
    //
    //     ///I
    //     'q45': fields[fields.indexWhere((e) => e.name == 'q45')].stringValue,
    //     'q46': fields[fields.indexWhere((e) => e.name == 'q46')].stringValue,
    //     'q47': fields[fields.indexWhere((e) => e.name == 'q47')].stringValue,
    //     'qi_comment': fields[fields.indexWhere((e) => e.name == 'qi_comment')]
    //         .stringValue,
    //
    //     ///J
    //     'q48': fields[fields.indexWhere((e) => e.name == 'q48')].stringValue,
    //     'q49': fields[fields.indexWhere((e) => e.name == 'q49')].stringValue,
    //     'q50': fields[fields.indexWhere((e) => e.name == 'q50')].stringValue,
    //     'qj_comment': fields[fields.indexWhere((e) => e.name == 'qi_comment')]
    //         .stringValue,
    //
    //     ///K
    //     'q51': fields[fields.indexWhere((e) => e.name == 'q51')].stringValue,
    //     'q52_detail': fields[fields.indexWhere((e) => e.name == 'q52_detail')].stringValue,
    //     'q52': fields[fields.indexWhere((e) => e.name == 'q52')].stringValue,
    //     'q53_detail': fields[fields.indexWhere((e) => e.name == 'q53_detail')].stringValue,
    //     'q53': fields[fields.indexWhere((e) => e.name == 'q53')].stringValue,
    //     'q54_detail': fields[fields.indexWhere((e) => e.name == 'q54_detail')].stringValue,
    //     'q54': fields[fields.indexWhere((e) => e.name == 'q54')].stringValue,
    //     'q55_detail': fields[fields.indexWhere((e) => e.name == 'q55_detail')].stringValue,
    //     'q55': fields[fields.indexWhere((e) => e.name == 'q55')].stringValue,
    //     'qk_comment': fields[fields.indexWhere((e) => e.name == 'qk_comment')]
    //         .stringValue,
    //
    //     ///LANDING AND GO-AROUND
    //     'no_landing': fields[fields.indexWhere((e) => e.name == 'no_landing')]
    //         .stringValue,
    //     'no_goaround': fields[fields.indexWhere((e) => e.name == 'no_goaround')]
    //         .stringValue,
    //
    //     ///COMPETENCY
    //     'comp_kno':
    //     fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
    //     'comp_pro':
    //     fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
    //     'comp_com':
    //     fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
    //     'comp_fpa':
    //     fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
    //     'comp_fpm':
    //     fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
    //     'comp_ltw':
    //     fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
    //     'comp_psd':
    //     fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
    //     'comp_saw':
    //     fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
    //     'comp_wlm':
    //     fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
    //     'general_comment':
    //     fields[fields.indexWhere((e) => e.name == 'general_comment')]
    //         .stringValue,
    //
    //     ///RESULT
    //     'result':
    //     fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //
    //     'pilot_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
    //         .stringValue,
    //     'instructor_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_sig_date')]
    //         .stringValue,
    //   };
    // } else if (type == FormType.rt5) {
    //   return {
    //     ///----------------------------------------------------------------------
    //     ///HEADER
    //     ///----------------------------------------------------------------------
    //     ///Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //
    //     ///----------------------------------------------------------------------
    //     ///ITEM
    //     ///----------------------------------------------------------------------
    //     ///Pilot info.
    //     'pilot_rank': fields[fields.indexWhere((e) => e.name == 'pilot_rank')]
    //         .stringValue,
    //     'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
    //         .stringValue,
    //     'pilot_license_no':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
    //             .stringValue,
    //     'pilot_id':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
    //
    //     ///Instructor info.
    //     'instructor_rank':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_rank')]
    //             .stringValue,
    //     'instructor_name':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_name')]
    //             .stringValue,
    //     'instructor_cert_no':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_cert_no')]
    //             .stringValue,
    //     'instructor_id':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_id')]
    //             .stringValue,
    //
    //     //Check details
    //     'check_date': fields[fields.indexWhere((e) => e.name == 'check_date')]
    //         .stringValue,
    //     'block_time': fields[fields.indexWhere((e) => e.name == 'block_time')]
    //         .stringValue,
    //     'fstd_no':
    //         fields[fields.indexWhere((e) => e.name == 'fstd_no')].stringValue,
    //
    //     ///Grading & Comment
    //     ///A
    //     'q1': fields[fields.indexWhere((e) => e.name == 'q1')].stringValue,
    //     'q2': fields[fields.indexWhere((e) => e.name == 'q2')].stringValue,
    //     'q3': fields[fields.indexWhere((e) => e.name == 'q3')].stringValue,
    //     'q4': fields[fields.indexWhere((e) => e.name == 'q4')].stringValue,
    //     'qa_comment': fields[fields.indexWhere((e) => e.name == 'qa_comment')]
    //         .stringValue,
    //
    //     ///B
    //     'qb': fields[fields.indexWhere((e) => e.name == 'qb')].stringValue,
    //     'q5': fields[fields.indexWhere((e) => e.name == 'q5')].stringValue,
    //     'q6': fields[fields.indexWhere((e) => e.name == 'q6')].stringValue,
    //     'q7': fields[fields.indexWhere((e) => e.name == 'q7')].stringValue,
    //     'q8': fields[fields.indexWhere((e) => e.name == 'q8')].stringValue,
    //     'q9': fields[fields.indexWhere((e) => e.name == 'q9')].stringValue,
    //     'q10': fields[fields.indexWhere((e) => e.name == 'q10')].stringValue,
    //     'q11': fields[fields.indexWhere((e) => e.name == 'q11')].stringValue,
    //     'q12': fields[fields.indexWhere((e) => e.name == 'q12')].stringValue,
    //     'q13_check_0': fields[fields.indexWhere((e) => e.name == 'q13_check_0')]
    //         .stringValue,
    //     'q13_check_1': fields[fields.indexWhere((e) => e.name == 'q13_check_1')]
    //         .stringValue,
    //     'q13_check_2': fields[fields.indexWhere((e) => e.name == 'q13_check_2')]
    //         .stringValue,
    //     'q13_check_3': fields[fields.indexWhere((e) => e.name == 'q13_check_3')]
    //         .stringValue,
    //     'q13': fields[fields.indexWhere((e) => e.name == 'q13')].stringValue,
    //     'q14': fields[fields.indexWhere((e) => e.name == 'q14')].stringValue,
    //     'q15': fields[fields.indexWhere((e) => e.name == 'q15')].stringValue,
    //     'q16_check_0': fields[fields.indexWhere((e) => e.name == 'q16_check_0')]
    //         .stringValue,
    //     'q16_check_1': fields[fields.indexWhere((e) => e.name == 'q16_check_1')]
    //         .stringValue,
    //     'q16': fields[fields.indexWhere((e) => e.name == 'q16')].stringValue,
    //     'q17_check_0': fields[fields.indexWhere((e) => e.name == 'q17_check_0')]
    //         .stringValue,
    //     'q17_check_1': fields[fields.indexWhere((e) => e.name == 'q17_check_1')]
    //         .stringValue,
    //     'q17': fields[fields.indexWhere((e) => e.name == 'q17')].stringValue,
    //     'q18_check_0': fields[fields.indexWhere((e) => e.name == 'q18_check_0')]
    //         .stringValue,
    //     'q18_check_1': fields[fields.indexWhere((e) => e.name == 'q18_check_1')]
    //         .stringValue,
    //     'q18_check_2': fields[fields.indexWhere((e) => e.name == 'q18_check_2')]
    //         .stringValue,
    //     'q18': fields[fields.indexWhere((e) => e.name == 'q18')].stringValue,
    //     'q19_check_0': fields[fields.indexWhere((e) => e.name == 'q19_check_0')]
    //         .stringValue,
    //     'q19_check_1': fields[fields.indexWhere((e) => e.name == 'q19_check_1')]
    //         .stringValue,
    //     'q19': fields[fields.indexWhere((e) => e.name == 'q19')].stringValue,
    //     'qb_comment': fields[fields.indexWhere((e) => e.name == 'qb_comment')]
    //         .stringValue,
    //
    //     ///C
    //     'q20': fields[fields.indexWhere((e) => e.name == 'q20')].stringValue,
    //     'q21': fields[fields.indexWhere((e) => e.name == 'q21')].stringValue,
    //     'qc_comment': fields[fields.indexWhere((e) => e.name == 'qc_comment')]
    //         .stringValue,
    //
    //     ///D
    //     'q22': fields[fields.indexWhere((e) => e.name == 'q22')].stringValue,
    //     'q23': fields[fields.indexWhere((e) => e.name == 'q23')].stringValue,
    //     'q24': fields[fields.indexWhere((e) => e.name == 'q24')].stringValue,
    //     'q25_check_0': fields[fields.indexWhere((e) => e.name == 'q25_check_0')]
    //         .stringValue,
    //     'q25_check_1': fields[fields.indexWhere((e) => e.name == 'q25_check_1')]
    //         .stringValue,
    //     'q25_check_2': fields[fields.indexWhere((e) => e.name == 'q25_check_2')]
    //         .stringValue,
    //     'q25': fields[fields.indexWhere((e) => e.name == 'q25')].stringValue,
    //     'q26': fields[fields.indexWhere((e) => e.name == 'q26')].stringValue,
    //     'q27': fields[fields.indexWhere((e) => e.name == 'q27')].stringValue,
    //     'q28': fields[fields.indexWhere((e) => e.name == 'q28')].stringValue,
    //     'qd_comment': fields[fields.indexWhere((e) => e.name == 'qd_comment')]
    //         .stringValue,
    //
    //     ///E
    //     'q29': fields[fields.indexWhere((e) => e.name == 'q29')].stringValue,
    //     'q30': fields[fields.indexWhere((e) => e.name == 'q30')].stringValue,
    //     'q31': fields[fields.indexWhere((e) => e.name == 'q31')].stringValue,
    //     'q32': fields[fields.indexWhere((e) => e.name == 'q32')].stringValue,
    //     'qe_comment': fields[fields.indexWhere((e) => e.name == 'qe_comment')]
    //         .stringValue,
    //
    //     ///F
    //     'q33': fields[fields.indexWhere((e) => e.name == 'q33')].stringValue,
    //     'q34': fields[fields.indexWhere((e) => e.name == 'q34')].stringValue,
    //     'q35': fields[fields.indexWhere((e) => e.name == 'q35')].stringValue,
    //     'q36': fields[fields.indexWhere((e) => e.name == 'q36')].stringValue,
    //     'q37': fields[fields.indexWhere((e) => e.name == 'q37')].stringValue,
    //     'qf_comment': fields[fields.indexWhere((e) => e.name == 'qf_comment')]
    //         .stringValue,
    //
    //     ///G
    //     'q38': fields[fields.indexWhere((e) => e.name == 'q38')].stringValue,
    //     'q39': fields[fields.indexWhere((e) => e.name == 'q39')].stringValue,
    //     'q40': fields[fields.indexWhere((e) => e.name == 'q40')].stringValue,
    //     'q41': fields[fields.indexWhere((e) => e.name == 'q41')].stringValue,
    //     'qg_comment': fields[fields.indexWhere((e) => e.name == 'qg_comment')]
    //         .stringValue,
    //
    //     ///H
    //     'q42': fields[fields.indexWhere((e) => e.name == 'q42')].stringValue,
    //     'q43': fields[fields.indexWhere((e) => e.name == 'q43')].stringValue,
    //     'q44_detail': fields[fields.indexWhere((e) => e.name == 'q44_detail')]
    //         .stringValue,
    //     'q44': fields[fields.indexWhere((e) => e.name == 'q44')].stringValue,
    //     'q45_detail': fields[fields.indexWhere((e) => e.name == 'q45_detail')]
    //         .stringValue,
    //     'q45': fields[fields.indexWhere((e) => e.name == 'q45')].stringValue,
    //     'q46_detail': fields[fields.indexWhere((e) => e.name == 'q46_detail')]
    //         .stringValue,
    //     'q46': fields[fields.indexWhere((e) => e.name == 'q46')].stringValue,
    //     'q47_detail': fields[fields.indexWhere((e) => e.name == 'q47_detail')]
    //         .stringValue,
    //     'q47': fields[fields.indexWhere((e) => e.name == 'q47')].stringValue,
    //     'q48_detail': fields[fields.indexWhere((e) => e.name == 'q48_detail')]
    //         .stringValue,
    //     'q48': fields[fields.indexWhere((e) => e.name == 'q48')].stringValue,
    //     'q49_detail': fields[fields.indexWhere((e) => e.name == 'q49_detail')]
    //         .stringValue,
    //     'q49': fields[fields.indexWhere((e) => e.name == 'q49')].stringValue,
    //     'q50_detail': fields[fields.indexWhere((e) => e.name == 'q50_detail')]
    //         .stringValue,
    //     'q50': fields[fields.indexWhere((e) => e.name == 'q50')].stringValue,
    //     'qh_comment': fields[fields.indexWhere((e) => e.name == 'qh_comment')]
    //         .stringValue,
    //
    //     ///LANDING AND GO-AROUND
    //     'no_landing': fields[fields.indexWhere((e) => e.name == 'no_landing')]
    //         .stringValue,
    //     'no_goaround': fields[fields.indexWhere((e) => e.name == 'no_goaround')]
    //         .stringValue,
    //
    //     ///COMPETENCY
    //     'comp_kno':
    //         fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
    //     'comp_pro':
    //         fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
    //     'comp_com':
    //         fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
    //     'comp_fpa':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
    //     'comp_fpm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
    //     'comp_ltw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
    //     'comp_psd':
    //         fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
    //     'comp_saw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
    //     'comp_wlm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
    //     'general_comment':
    //         fields[fields.indexWhere((e) => e.name == 'general_comment')]
    //             .stringValue,
    //
    //     ///RESULT
    //     'result':
    //         fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //
    //     'pilot_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
    //             .stringValue,
    //     'instructor_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_sig_date')]
    //             .stringValue,
    //   };
    // } else if (type == FormType.rt6) {
    //   return {
    //     ///----------------------------------------------------------------------
    //     ///HEADER
    //     ///----------------------------------------------------------------------
    //     ///Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //
    //     ///----------------------------------------------------------------------
    //     ///ITEM
    //     ///----------------------------------------------------------------------
    //     ///Pilot info.
    //     'pilot_rank': fields[fields.indexWhere((e) => e.name == 'pilot_rank')]
    //         .stringValue,
    //     'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
    //         .stringValue,
    //     'pilot_license_no':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
    //         .stringValue,
    //     'pilot_id':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
    //
    //     ///Instructor info.
    //     'instructor_rank':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_rank')]
    //         .stringValue,
    //     'instructor_name':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_name')]
    //         .stringValue,
    //     'instructor_cert_no':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_cert_no')]
    //         .stringValue,
    //     'instructor_id':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_id')]
    //         .stringValue,
    //
    //     //Check details
    //     'check_date': fields[fields.indexWhere((e) => e.name == 'check_date')]
    //         .stringValue,
    //     'block_time': fields[fields.indexWhere((e) => e.name == 'block_time')]
    //         .stringValue,
    //     'fstd_no':
    //     fields[fields.indexWhere((e) => e.name == 'fstd_no')].stringValue,
    //     'loft_duty':
    //     fields[fields.indexWhere((e) => e.name == 'loft_duty')].stringValue,
    //
    //     ///Grading & Comment
    //     ///A
    //     'q1': fields[fields.indexWhere((e) => e.name == 'q1')].stringValue,
    //     'q2': fields[fields.indexWhere((e) => e.name == 'q2')].stringValue,
    //     'q3': fields[fields.indexWhere((e) => e.name == 'q3')].stringValue,
    //     'q4': fields[fields.indexWhere((e) => e.name == 'q4')].stringValue,
    //     'qa_comment': fields[fields.indexWhere((e) => e.name == 'qa_comment')]
    //         .stringValue,
    //
    //     ///B
    //     'q5': fields[fields.indexWhere((e) => e.name == 'q5')].stringValue,
    //     'q6_detail': fields[fields.indexWhere((e) => e.name == 'q6_detail')].stringValue,
    //     'q6': fields[fields.indexWhere((e) => e.name == 'q6')].stringValue,
    //     'q7': fields[fields.indexWhere((e) => e.name == 'q7')].stringValue,
    //     'qb_comment': fields[fields.indexWhere((e) => e.name == 'qb_comment')]
    //         .stringValue,
    //
    //     ///C
    //     'q8': fields[fields.indexWhere((e) => e.name == 'q8')].stringValue,
    //     'q9': fields[fields.indexWhere((e) => e.name == 'q9')].stringValue,
    //     'q10': fields[fields.indexWhere((e) => e.name == 'q10')].stringValue,
    //     'q11': fields[fields.indexWhere((e) => e.name == 'q11')].stringValue,
    //     'qc_comment': fields[fields.indexWhere((e) => e.name == 'qc_comment')]
    //         .stringValue,
    //
    //     ///D
    //     'q12': fields[fields.indexWhere((e) => e.name == 'q12')].stringValue,
    //     'q13': fields[fields.indexWhere((e) => e.name == 'q13')].stringValue,
    //     'q14': fields[fields.indexWhere((e) => e.name == 'q14')].stringValue,
    //     'q15': fields[fields.indexWhere((e) => e.name == 'q15')].stringValue,
    //     'q16': fields[fields.indexWhere((e) => e.name == 'q16')].stringValue,
    //     'q17': fields[fields.indexWhere((e) => e.name == 'q17')].stringValue,
    //     'q18': fields[fields.indexWhere((e) => e.name == 'q18')].stringValue,
    //     'q19': fields[fields.indexWhere((e) => e.name == 'q19')].stringValue,
    //     'q20_check_0': fields[fields.indexWhere((e) => e.name == 'q20_check_0')]
    //         .stringValue,
    //     'q20_check_1': fields[fields.indexWhere((e) => e.name == 'q20_check_1')]
    //         .stringValue,
    //     'q20_check_2': fields[fields.indexWhere((e) => e.name == 'q20_check_2')]
    //         .stringValue,
    //     'q20': fields[fields.indexWhere((e) => e.name == 'q20')].stringValue,
    //     'q21_check_0': fields[fields.indexWhere((e) => e.name == 'q21_check_0')]
    //         .stringValue,
    //     'q21_check_1': fields[fields.indexWhere((e) => e.name == 'q21_check_1')]
    //         .stringValue,
    //     'q21': fields[fields.indexWhere((e) => e.name == 'q21')].stringValue,
    //     'qd_comment': fields[fields.indexWhere((e) => e.name == 'qd_comment')]
    //         .stringValue,
    //
    //     ///E
    //     'q22': fields[fields.indexWhere((e) => e.name == 'q22')].stringValue,
    //     'q23': fields[fields.indexWhere((e) => e.name == 'q23')].stringValue,
    //     'q24': fields[fields.indexWhere((e) => e.name == 'q24')].stringValue,
    //     'qe_comment': fields[fields.indexWhere((e) => e.name == 'qe_comment')]
    //         .stringValue,
    //
    //     ///F
    //     'q25': fields[fields.indexWhere((e) => e.name == 'q25')].stringValue,
    //     'q26': fields[fields.indexWhere((e) => e.name == 'q26')].stringValue,
    //     'q27': fields[fields.indexWhere((e) => e.name == 'q27')].stringValue,
    //     'q28': fields[fields.indexWhere((e) => e.name == 'q28')].stringValue,
    //     'q29': fields[fields.indexWhere((e) => e.name == 'q29')].stringValue,
    //     'q30': fields[fields.indexWhere((e) => e.name == 'q30')].stringValue,
    //     'q31': fields[fields.indexWhere((e) => e.name == 'q31')].stringValue,
    //     'q32': fields[fields.indexWhere((e) => e.name == 'q32')].stringValue,
    //     'q33': fields[fields.indexWhere((e) => e.name == 'q33')].stringValue,
    //     'q34_check_0': fields[fields.indexWhere((e) => e.name == 'q34_check_0')]
    //         .stringValue,
    //     'q34_check_1': fields[fields.indexWhere((e) => e.name == 'q34_check_1')]
    //         .stringValue,
    //     'q34': fields[fields.indexWhere((e) => e.name == 'q34')].stringValue,
    //     'q35': fields[fields.indexWhere((e) => e.name == 'q35')].stringValue,
    //     'qf_comment': fields[fields.indexWhere((e) => e.name == 'qf_comment')]
    //         .stringValue,
    //
    //     ///G
    //     'q36': fields[fields.indexWhere((e) => e.name == 'q36')].stringValue,
    //     'q37': fields[fields.indexWhere((e) => e.name == 'q37')].stringValue,
    //     'q38': fields[fields.indexWhere((e) => e.name == 'q38')].stringValue,
    //     'qg_comment': fields[fields.indexWhere((e) => e.name == 'qg_comment')]
    //         .stringValue,
    //
    //     ///H
    //     'q39': fields[fields.indexWhere((e) => e.name == 'q39')].stringValue,
    //     'q40': fields[fields.indexWhere((e) => e.name == 'q40')].stringValue,
    //     'q41': fields[fields.indexWhere((e) => e.name == 'q41')].stringValue,
    //     'q42': fields[fields.indexWhere((e) => e.name == 'q42')].stringValue,
    //     'q43': fields[fields.indexWhere((e) => e.name == 'q43')].stringValue,
    //     'qh_comment': fields[fields.indexWhere((e) => e.name == 'qh_comment')]
    //         .stringValue,
    //
    //     ///I
    //     'q44': fields[fields.indexWhere((e) => e.name == 'q44')].stringValue,
    //     'q45': fields[fields.indexWhere((e) => e.name == 'q45')].stringValue,
    //     'q46': fields[fields.indexWhere((e) => e.name == 'q46')].stringValue,
    //     'qi_comment': fields[fields.indexWhere((e) => e.name == 'qi_comment')]
    //         .stringValue,
    //
    //     ///J
    //     'q47': fields[fields.indexWhere((e) => e.name == 'q47')].stringValue,
    //     'q48': fields[fields.indexWhere((e) => e.name == 'q48')].stringValue,
    //     'q49': fields[fields.indexWhere((e) => e.name == 'q49')].stringValue,
    //     'qj_comment': fields[fields.indexWhere((e) => e.name == 'qi_comment')]
    //         .stringValue,
    //
    //     ///K
    //     'q50': fields[fields.indexWhere((e) => e.name == 'q50')].stringValue,
    //     'q51_detail': fields[fields.indexWhere((e) => e.name == 'q51_detail')].stringValue,
    //     'q51': fields[fields.indexWhere((e) => e.name == 'q51')].stringValue,
    //     'q52_detail': fields[fields.indexWhere((e) => e.name == 'q52_detail')].stringValue,
    //     'q52': fields[fields.indexWhere((e) => e.name == 'q52')].stringValue,
    //     'q53_detail': fields[fields.indexWhere((e) => e.name == 'q53_detail')].stringValue,
    //     'q53': fields[fields.indexWhere((e) => e.name == 'q53')].stringValue,
    //     'q54_detail': fields[fields.indexWhere((e) => e.name == 'q54_detail')].stringValue,
    //     'q54': fields[fields.indexWhere((e) => e.name == 'q54')].stringValue,
    //     'qk_comment': fields[fields.indexWhere((e) => e.name == 'qk_comment')]
    //         .stringValue,
    //
    //     ///LANDING AND GO-AROUND
    //     'no_landing': fields[fields.indexWhere((e) => e.name == 'no_landing')]
    //         .stringValue,
    //     'no_goaround': fields[fields.indexWhere((e) => e.name == 'no_goaround')]
    //         .stringValue,
    //
    //     ///COMPETENCY
    //     'comp_kno':
    //     fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
    //     'comp_pro':
    //     fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
    //     'comp_com':
    //     fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
    //     'comp_fpa':
    //     fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
    //     'comp_fpm':
    //     fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
    //     'comp_ltw':
    //     fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
    //     'comp_psd':
    //     fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
    //     'comp_saw':
    //     fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
    //     'comp_wlm':
    //     fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
    //     'general_comment':
    //     fields[fields.indexWhere((e) => e.name == 'general_comment')]
    //         .stringValue,
    //
    //     ///RESULT
    //     'result':
    //     fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //
    //     'pilot_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
    //         .stringValue,
    //     'instructor_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'instructor_sig_date')]
    //         .stringValue,
    //   };
    // } else if (type == FormType.lineTrain) {
    //   return {
    //     ///----------------------------------------------------------------------
    //     ///HEADER
    //     ///----------------------------------------------------------------------
    //     ///Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //
    //     ///----------------------------------------------------------------------
    //     ///ITEM
    //     ///----------------------------------------------------------------------
    //     ///Pilot info.
    //     'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
    //         .stringValue,
    //     'pilot_license_no':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
    //             .stringValue,
    //     'pilot_id':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
    //
    //     ///Instructor info.
    //     'instructor_name':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_name')]
    //             .stringValue,
    //     'instructor_cert_no':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_cert_no')]
    //             .stringValue,
    //     'instructor_id':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_id')]
    //             .stringValue,
    //
    //     ///Examiner / CAAT info.
    //     'examiner_name':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_name')]
    //             .stringValue,
    //     'examiner_license_no':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_license_no')]
    //             .stringValue,
    //     'examiner_id': fields[fields.indexWhere((e) => e.name == 'examiner_id')]
    //         .stringValue,
    //
    //     ///Check details
    //     'course':
    //         fields[fields.indexWhere((e) => e.name == 'course')].stringValue,
    //     'other_course':
    //         fields[fields.indexWhere((e) => e.name == 'other_course')]
    //             .stringValue,
    //     // 'check_type': fields[fields.indexWhere((e) => e.name == 'check_type')].stringValue,
    //     'check_type_0':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_0')]
    //             .stringValue,
    //     'check_type_1':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_1')]
    //             .stringValue,
    //     'check_type_2':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_2')]
    //             .stringValue,
    //     'check_type_3':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_3')]
    //             .stringValue,
    //     'check_type_4':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_4')]
    //             .stringValue,
    //     'check_type_5':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_5')]
    //             .stringValue,
    //     'check_type_6':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_6')]
    //             .stringValue,
    //     'check_type_7':
    //         fields[fields.indexWhere((e) => e.name == 'check_type_7')]
    //             .stringValue,
    //     'other_type': fields[fields.indexWhere((e) => e.name == 'other_type')]
    //         .stringValue,
    //
    //     ///Sector
    //     'date_1':
    //         fields[fields.indexWhere((e) => e.name == 'date_1')].stringValue,
    //     'ac_type_1':
    //         fields[fields.indexWhere((e) => e.name == 'ac_type_1')].stringValue,
    //     'ac_reg_1':
    //         fields[fields.indexWhere((e) => e.name == 'ac_reg_1')].stringValue,
    //     'flt_no_1':
    //         fields[fields.indexWhere((e) => e.name == 'flt_no_1')].stringValue,
    //     'route_1':
    //         fields[fields.indexWhere((e) => e.name == 'route_1')].stringValue,
    //     'duty_1':
    //         fields[fields.indexWhere((e) => e.name == 'duty_1')].stringValue,
    //     'date_2':
    //         fields[fields.indexWhere((e) => e.name == 'date_2')].stringValue,
    //     'ac_type_2':
    //         fields[fields.indexWhere((e) => e.name == 'ac_type_2')].stringValue,
    //     'ac_reg_2':
    //         fields[fields.indexWhere((e) => e.name == 'ac_reg_2')].stringValue,
    //     'flt_no_2':
    //         fields[fields.indexWhere((e) => e.name == 'flt_no_2')].stringValue,
    //     'route_2':
    //         fields[fields.indexWhere((e) => e.name == 'route_2')].stringValue,
    //     'duty_2':
    //         fields[fields.indexWhere((e) => e.name == 'duty_2')].stringValue,
    //
    //     'accum_pf':
    //         fields[fields.indexWhere((e) => e.name == 'accum_pf')].stringValue,
    //     'accum_pm':
    //         fields[fields.indexWhere((e) => e.name == 'accum_pm')].stringValue,
    //
    //     ///Grading & Comment
    //     ///A
    //     'q1': fields[fields.indexWhere((e) => e.name == 'q1')].stringValue,
    //     'q2': fields[fields.indexWhere((e) => e.name == 'q2')].stringValue,
    //     'q3': fields[fields.indexWhere((e) => e.name == 'q3')].stringValue,
    //     'q4': fields[fields.indexWhere((e) => e.name == 'q4')].stringValue,
    //     'q5': fields[fields.indexWhere((e) => e.name == 'q5')].stringValue,
    //     'q6': fields[fields.indexWhere((e) => e.name == 'q6')].stringValue,
    //     'q7': fields[fields.indexWhere((e) => e.name == 'q7')].stringValue,
    //     'q8': fields[fields.indexWhere((e) => e.name == 'q8')].stringValue,
    //     'q9': fields[fields.indexWhere((e) => e.name == 'q9')].stringValue,
    //     'qa_comment': fields[fields.indexWhere((e) => e.name == 'qa_comment')]
    //         .stringValue,
    //
    //     ///B
    //     'q10': fields[fields.indexWhere((e) => e.name == 'q10')].stringValue,
    //     'q11': fields[fields.indexWhere((e) => e.name == 'q11')].stringValue,
    //     'q12': fields[fields.indexWhere((e) => e.name == 'q12')].stringValue,
    //     'qb_comment': fields[fields.indexWhere((e) => e.name == 'qb_comment')]
    //         .stringValue,
    //
    //     ///C
    //     'q13': fields[fields.indexWhere((e) => e.name == 'q13')].stringValue,
    //     'q14': fields[fields.indexWhere((e) => e.name == 'q14')].stringValue,
    //     'q15': fields[fields.indexWhere((e) => e.name == 'q15')].stringValue,
    //     'q16': fields[fields.indexWhere((e) => e.name == 'q16')].stringValue,
    //     'q17': fields[fields.indexWhere((e) => e.name == 'q17')].stringValue,
    //     'q18': fields[fields.indexWhere((e) => e.name == 'q18')].stringValue,
    //     'q19': fields[fields.indexWhere((e) => e.name == 'q19')].stringValue,
    //     'q20': fields[fields.indexWhere((e) => e.name == 'q20')].stringValue,
    //     'qc_comment': fields[fields.indexWhere((e) => e.name == 'qc_comment')]
    //         .stringValue,
    //
    //     ///D
    //     'q21': fields[fields.indexWhere((e) => e.name == 'q21')].stringValue,
    //     'q22': fields[fields.indexWhere((e) => e.name == 'q22')].stringValue,
    //     'q23': fields[fields.indexWhere((e) => e.name == 'q23')].stringValue,
    //     'q24': fields[fields.indexWhere((e) => e.name == 'q24')].stringValue,
    //     'q25': fields[fields.indexWhere((e) => e.name == 'q25')].stringValue,
    //     'q26': fields[fields.indexWhere((e) => e.name == 'q26')].stringValue,
    //     'qd_comment': fields[fields.indexWhere((e) => e.name == 'qd_comment')]
    //         .stringValue,
    //
    //     ///E
    //     'q27': fields[fields.indexWhere((e) => e.name == 'q27')].stringValue,
    //     'q28': fields[fields.indexWhere((e) => e.name == 'q28')].stringValue,
    //     'q29': fields[fields.indexWhere((e) => e.name == 'q29')].stringValue,
    //     'qe_comment': fields[fields.indexWhere((e) => e.name == 'qe_comment')]
    //         .stringValue,
    //
    //     ///F
    //     'q30': fields[fields.indexWhere((e) => e.name == 'q30')].stringValue,
    //     'q31': fields[fields.indexWhere((e) => e.name == 'q31')].stringValue,
    //     'q32': fields[fields.indexWhere((e) => e.name == 'q32')].stringValue,
    //     'q33': fields[fields.indexWhere((e) => e.name == 'q33')].stringValue,
    //     'q34': fields[fields.indexWhere((e) => e.name == 'q34')].stringValue,
    //     'q35': fields[fields.indexWhere((e) => e.name == 'q35')].stringValue,
    //     'qf_comment': fields[fields.indexWhere((e) => e.name == 'qf_comment')]
    //         .stringValue,
    //
    //     ///G
    //     'q36': fields[fields.indexWhere((e) => e.name == 'q36')].stringValue,
    //     'q37_detail': fields[fields.indexWhere((e) => e.name == 'q37_detail')]
    //         .stringValue,
    //     'q37': fields[fields.indexWhere((e) => e.name == 'q37')].stringValue,
    //     'q38_detail': fields[fields.indexWhere((e) => e.name == 'q38_detail')]
    //         .stringValue,
    //     'q38': fields[fields.indexWhere((e) => e.name == 'q38')].stringValue,
    //     'q39_detail': fields[fields.indexWhere((e) => e.name == 'q39_detail')]
    //         .stringValue,
    //     'q39': fields[fields.indexWhere((e) => e.name == 'q39')].stringValue,
    //     'q40_detail': fields[fields.indexWhere((e) => e.name == 'q40_detail')]
    //         .stringValue,
    //     'q40': fields[fields.indexWhere((e) => e.name == 'q40')].stringValue,
    //     'qg_comment': fields[fields.indexWhere((e) => e.name == 'qg_comment')]
    //         .stringValue,
    //
    //     ///COMPETENCY
    //     'comp_kno':
    //         fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
    //     'comp_pro':
    //         fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
    //     'comp_com':
    //         fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
    //     'comp_fpa':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
    //     'comp_fpm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
    //     'comp_ltw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
    //     'comp_psd':
    //         fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
    //     'comp_saw':
    //         fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
    //     'comp_wlm':
    //         fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
    //     'general_comment':
    //         fields[fields.indexWhere((e) => e.name == 'general_comment')]
    //             .stringValue,
    //     'additional_note':
    //         fields[fields.indexWhere((e) => e.name == 'additional_note')]
    //             .stringValue,
    //
    //     ///RESULT
    //     'result':
    //         fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //     'examiner_result':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_result')]
    //             .stringValue,
    //     'pilot_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
    //             .stringValue,
    //     'instructor_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'instructor_sig_date')]
    //             .stringValue,
    //     'examiner_sig_date':
    //         fields[fields.indexWhere((e) => e.name == 'examiner_sig_date')]
    //             .stringValue,
    //   };
    // } else if (type == FormType.ccc) {
    //   return {
    //     ///----------------------------------------------------------------------
    //     ///HEADER
    //     ///----------------------------------------------------------------------
    //     ///Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //
    //     ///----------------------------------------------------------------------
    //     ///ITEM
    //     ///----------------------------------------------------------------------
    //     ///Trainee info.
    //     'trainee_name': fields[fields.indexWhere((e) => e.name == 'trainee_name')]
    //         .stringValue,
    //     'trainee_id':
    //     fields[fields.indexWhere((e) => e.name == 'trainee_id')]
    //         .stringValue,
    //
    //     ///Purser info.
    //     'purser_name':
    //     fields[fields.indexWhere((e) => e.name == 'purser_name')]
    //         .stringValue,
    //     'purser_id':
    //     fields[fields.indexWhere((e) => e.name == 'purser_id')]
    //         .stringValue,
    //
    //     ///Evaluator
    //     'evaluator_name':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_name')]
    //         .stringValue,
    //     'evaluator_id':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_id')]
    //         .stringValue,
    //
    //     ///Flight details
    //     'check_date':
    //     fields[fields.indexWhere((e) => e.name == 'check_date')].stringValue,
    //     'check_course':
    //     fields[fields.indexWhere((e) => e.name == 'check_course')]
    //         .stringValue,
    //     'other_course':
    //     fields[fields.indexWhere((e) => e.name == 'other_course')]
    //         .stringValue,
    //     'check_type':
    //     fields[fields.indexWhere((e) => e.name == 'check_type')]
    //         .stringValue,
    //     'position':
    //     fields[fields.indexWhere((e) => e.name == 'position')]
    //         .stringValue,
    //     'ac_type':
    //     fields[fields.indexWhere((e) => e.name == 'ac_type')]
    //         .stringValue,
    //     'ac_reg':
    //     fields[fields.indexWhere((e) => e.name == 'ac_reg')]
    //         .stringValue,
    //     'flight':
    //     fields[fields.indexWhere((e) => e.name == 'flight')]
    //         .stringValue,
    //     'route':
    //     fields[fields.indexWhere((e) => e.name == 'route')]
    //         .stringValue,
    //
    //
    //     ///Grading & Comment
    //     ///A
    //     'q1': fields[fields.indexWhere((e) => e.name == 'q1')].stringValue,
    //     'q2': fields[fields.indexWhere((e) => e.name == 'q2')].stringValue,
    //     'q3': fields[fields.indexWhere((e) => e.name == 'q3')].stringValue,
    //     'q4': fields[fields.indexWhere((e) => e.name == 'q4')].stringValue,
    //     'q5': fields[fields.indexWhere((e) => e.name == 'q5')].stringValue,
    //     'q6': fields[fields.indexWhere((e) => e.name == 'q6')].stringValue,
    //     'qa_comment': fields[fields.indexWhere((e) => e.name == 'qa_comment')]
    //         .stringValue,
    //
    //     ///B
    //     'q7': fields[fields.indexWhere((e) => e.name == 'q7')].stringValue,
    //     'q8': fields[fields.indexWhere((e) => e.name == 'q8')].stringValue,
    //     'q9': fields[fields.indexWhere((e) => e.name == 'q9')].stringValue,
    //     'q10': fields[fields.indexWhere((e) => e.name == 'q10')].stringValue,
    //     'q11': fields[fields.indexWhere((e) => e.name == 'q11')].stringValue,
    //     'q12': fields[fields.indexWhere((e) => e.name == 'q12')].stringValue,
    //     'q13': fields[fields.indexWhere((e) => e.name == 'q13')].stringValue,
    //     'q14': fields[fields.indexWhere((e) => e.name == 'q14')].stringValue,
    //     'q15': fields[fields.indexWhere((e) => e.name == 'q15')].stringValue,
    //     'qb_comment': fields[fields.indexWhere((e) => e.name == 'qb_comment')]
    //         .stringValue,
    //
    //     ///C
    //     'q16': fields[fields.indexWhere((e) => e.name == 'q16')].stringValue,
    //     'q17': fields[fields.indexWhere((e) => e.name == 'q17')].stringValue,
    //     'q18': fields[fields.indexWhere((e) => e.name == 'q18')].stringValue,
    //     'q19': fields[fields.indexWhere((e) => e.name == 'q19')].stringValue,
    //     'q20': fields[fields.indexWhere((e) => e.name == 'q20')].stringValue,
    //     'qc_comment': fields[fields.indexWhere((e) => e.name == 'qc_comment')]
    //         .stringValue,
    //
    //     ///D
    //     'q21': fields[fields.indexWhere((e) => e.name == 'q21')].stringValue,
    //     'q22': fields[fields.indexWhere((e) => e.name == 'q22')].stringValue,
    //     'q23': fields[fields.indexWhere((e) => e.name == 'q23')].stringValue,
    //     'q24': fields[fields.indexWhere((e) => e.name == 'q24')].stringValue,
    //     'qd_comment': fields[fields.indexWhere((e) => e.name == 'qd_comment')]
    //         .stringValue,
    //
    //     ///E
    //     'q25': fields[fields.indexWhere((e) => e.name == 'q25')].stringValue,
    //     'q26': fields[fields.indexWhere((e) => e.name == 'q26')].stringValue,
    //     'q27': fields[fields.indexWhere((e) => e.name == 'q27')].stringValue,
    //     'q28': fields[fields.indexWhere((e) => e.name == 'q28')].stringValue,
    //     'q29': fields[fields.indexWhere((e) => e.name == 'q29')].stringValue,
    //     'qe_comment': fields[fields.indexWhere((e) => e.name == 'qe_comment')]
    //         .stringValue,
    //
    //     ///F
    //     'q30': fields[fields.indexWhere((e) => e.name == 'q30')].stringValue,
    //     'q31': fields[fields.indexWhere((e) => e.name == 'q31')].stringValue,
    //     'q32': fields[fields.indexWhere((e) => e.name == 'q32')].stringValue,
    //     'q33': fields[fields.indexWhere((e) => e.name == 'q33')].stringValue,
    //     'q34': fields[fields.indexWhere((e) => e.name == 'q34')].stringValue,
    //     'q35': fields[fields.indexWhere((e) => e.name == 'q35')].stringValue,
    //     'q36': fields[fields.indexWhere((e) => e.name == 'q36')].stringValue,
    //     'qf_comment': fields[fields.indexWhere((e) => e.name == 'qf_comment')]
    //         .stringValue,
    //
    //     ///G
    //     'q37': fields[fields.indexWhere((e) => e.name == 'q37')].stringValue,
    //     'q38': fields[fields.indexWhere((e) => e.name == 'q38')].stringValue,
    //     'q39': fields[fields.indexWhere((e) => e.name == 'q39')].stringValue,
    //     'q40': fields[fields.indexWhere((e) => e.name == 'q40')].stringValue,
    //     'qg_comment': fields[fields.indexWhere((e) => e.name == 'qg_comment')]
    //         .stringValue,
    //
    //     ///Additional Comment
    //     'additional_comment':
    //     fields[fields.indexWhere((e) => e.name == 'additional_comment')]
    //         .stringValue,
    //
    //     ///RESULT
    //     'result':
    //     fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //     'evaluator_result':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_result')]
    //         .stringValue,
    //     'trainee_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'trainee_sig_date')]
    //         .stringValue,
    //     'purser_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'purser_sig_date')]
    //         .stringValue,
    //     'evaluator_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_sig_date')]
    //         .stringValue,
    //   };
    // } else if (type == FormType.psc) {
    //   return {
    //     ///----------------------------------------------------------------------
    //     ///HEADER
    //     ///----------------------------------------------------------------------
    //     ///Form info.
    //     'status': status.toString(),
    //     'type': type.toString(),
    //     'form_name': formName,
    //     'create_at': createDateTime.toString(),
    //     'submit_at': submitDateTime != null ? submitDateTime.toString() : '',
    //     'create_by': createBy,
    //     'file_path': filePath,
    //     'id': id,
    //     'font_size': fontSize.round().toString(),
    //     'pdf_url': pdfUrl ?? '',
    //
    //     ///----------------------------------------------------------------------
    //     ///ITEM
    //     ///----------------------------------------------------------------------
    //     ///Trainee info.
    //     'trainee_name': fields[fields.indexWhere((e) => e.name == 'trainee_name')]
    //         .stringValue,
    //     'trainee_id':
    //     fields[fields.indexWhere((e) => e.name == 'trainee_id')]
    //         .stringValue,
    //
    //     ///Purser info.
    //     'purser_name':
    //     fields[fields.indexWhere((e) => e.name == 'purser_name')]
    //         .stringValue,
    //     'purser_id':
    //     fields[fields.indexWhere((e) => e.name == 'purser_id')]
    //         .stringValue,
    //
    //     ///Evaluator
    //     'evaluator_name':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_name')]
    //         .stringValue,
    //     'evaluator_id':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_id')]
    //         .stringValue,
    //
    //     ///Flight details
    //     'check_date':
    //     fields[fields.indexWhere((e) => e.name == 'check_date')].stringValue,
    //     'check_course':
    //     fields[fields.indexWhere((e) => e.name == 'check_course')]
    //         .stringValue,
    //     'check_type':
    //     fields[fields.indexWhere((e) => e.name == 'check_type')]
    //         .stringValue,
    //     'position':
    //     fields[fields.indexWhere((e) => e.name == 'position')]
    //         .stringValue,
    //     'ac_type':
    //     fields[fields.indexWhere((e) => e.name == 'ac_type')]
    //         .stringValue,
    //     'ac_reg':
    //     fields[fields.indexWhere((e) => e.name == 'ac_reg')]
    //         .stringValue,
    //     'flight':
    //     fields[fields.indexWhere((e) => e.name == 'flight')]
    //         .stringValue,
    //     'route':
    //     fields[fields.indexWhere((e) => e.name == 'route')]
    //         .stringValue,
    //
    //
    //     ///Grading & Comment
    //     ///A
    //     'q1': fields[fields.indexWhere((e) => e.name == 'q1')].stringValue,
    //     'q2': fields[fields.indexWhere((e) => e.name == 'q2')].stringValue,
    //     'q3': fields[fields.indexWhere((e) => e.name == 'q3')].stringValue,
    //     'q4': fields[fields.indexWhere((e) => e.name == 'q4')].stringValue,
    //     'q5': fields[fields.indexWhere((e) => e.name == 'q5')].stringValue,
    //     'q6': fields[fields.indexWhere((e) => e.name == 'q6')].stringValue,
    //     'q7': fields[fields.indexWhere((e) => e.name == 'q7')].stringValue,
    //     'q8': fields[fields.indexWhere((e) => e.name == 'q8')].stringValue,
    //     'q9': fields[fields.indexWhere((e) => e.name == 'q9')].stringValue,
    //     'q10': fields[fields.indexWhere((e) => e.name == 'q10')].stringValue,
    //     'q11': fields[fields.indexWhere((e) => e.name == 'q11')].stringValue,
    //     'q12': fields[fields.indexWhere((e) => e.name == 'q12')].stringValue,
    //     'q13': fields[fields.indexWhere((e) => e.name == 'q13')].stringValue,
    //     'q14': fields[fields.indexWhere((e) => e.name == 'q14')].stringValue,
    //     'q15': fields[fields.indexWhere((e) => e.name == 'q15')].stringValue,
    //     'qa_comment': fields[fields.indexWhere((e) => e.name == 'qa_comment')]
    //         .stringValue,
    //
    //     ///B
    //     'q16': fields[fields.indexWhere((e) => e.name == 'q16')].stringValue,
    //     'q17': fields[fields.indexWhere((e) => e.name == 'q17')].stringValue,
    //     'q18': fields[fields.indexWhere((e) => e.name == 'q18')].stringValue,
    //     'q19': fields[fields.indexWhere((e) => e.name == 'q19')].stringValue,
    //     'q20': fields[fields.indexWhere((e) => e.name == 'q20')].stringValue,
    //     'q21': fields[fields.indexWhere((e) => e.name == 'q21')].stringValue,
    //     'q22': fields[fields.indexWhere((e) => e.name == 'q22')].stringValue,
    //     'q23': fields[fields.indexWhere((e) => e.name == 'q23')].stringValue,
    //     'q24': fields[fields.indexWhere((e) => e.name == 'q24')].stringValue,
    //     'q25': fields[fields.indexWhere((e) => e.name == 'q25')].stringValue,
    //     'q26': fields[fields.indexWhere((e) => e.name == 'q26')].stringValue,
    //     'q27': fields[fields.indexWhere((e) => e.name == 'q27')].stringValue,
    //     'q28': fields[fields.indexWhere((e) => e.name == 'q28')].stringValue,
    //     'q29': fields[fields.indexWhere((e) => e.name == 'q29')].stringValue,
    //     'q30': fields[fields.indexWhere((e) => e.name == 'q30')].stringValue,
    //     'q31': fields[fields.indexWhere((e) => e.name == 'q31')].stringValue,
    //     'q32': fields[fields.indexWhere((e) => e.name == 'q32')].stringValue,
    //     'q33': fields[fields.indexWhere((e) => e.name == 'q33')].stringValue,
    //     'q34': fields[fields.indexWhere((e) => e.name == 'q34')].stringValue,
    //     'q35': fields[fields.indexWhere((e) => e.name == 'q35')].stringValue,
    //     'q36': fields[fields.indexWhere((e) => e.name == 'q36')].stringValue,
    //     'q37': fields[fields.indexWhere((e) => e.name == 'q37')].stringValue,
    //     'q38': fields[fields.indexWhere((e) => e.name == 'q38')].stringValue,
    //     'qb_comment': fields[fields.indexWhere((e) => e.name == 'qb_comment')]
    //         .stringValue,
    //
    //     ///C
    //     'q39': fields[fields.indexWhere((e) => e.name == 'q39')].stringValue,
    //     'q40': fields[fields.indexWhere((e) => e.name == 'q40')].stringValue,
    //     'q41': fields[fields.indexWhere((e) => e.name == 'q41')].stringValue,
    //     'q42': fields[fields.indexWhere((e) => e.name == 'q42')].stringValue,
    //     'q43': fields[fields.indexWhere((e) => e.name == 'q43')].stringValue,
    //     'q44': fields[fields.indexWhere((e) => e.name == 'q44')].stringValue,
    //     'q45': fields[fields.indexWhere((e) => e.name == 'q45')].stringValue,
    //     'qc_comment': fields[fields.indexWhere((e) => e.name == 'qc_comment')]
    //         .stringValue,
    //
    //     ///D
    //     'q46': fields[fields.indexWhere((e) => e.name == 'q46')].stringValue,
    //     'q47': fields[fields.indexWhere((e) => e.name == 'q47')].stringValue,
    //     'q48': fields[fields.indexWhere((e) => e.name == 'q48')].stringValue,
    //     'q49': fields[fields.indexWhere((e) => e.name == 'q49')].stringValue,
    //     'q50': fields[fields.indexWhere((e) => e.name == 'q50')].stringValue,
    //     'q51': fields[fields.indexWhere((e) => e.name == 'q51')].stringValue,
    //     'q52': fields[fields.indexWhere((e) => e.name == 'q52')].stringValue,
    //     'q53': fields[fields.indexWhere((e) => e.name == 'q53')].stringValue,
    //     'q54': fields[fields.indexWhere((e) => e.name == 'q54')].stringValue,
    //     'q55': fields[fields.indexWhere((e) => e.name == 'q55')].stringValue,
    //     'qd_comment': fields[fields.indexWhere((e) => e.name == 'qd_comment')]
    //         .stringValue,
    //
    //     ///E
    //     'q56': fields[fields.indexWhere((e) => e.name == 'q56')].stringValue,
    //     'q57': fields[fields.indexWhere((e) => e.name == 'q57')].stringValue,
    //     'q58': fields[fields.indexWhere((e) => e.name == 'q58')].stringValue,
    //     'qe_comment': fields[fields.indexWhere((e) => e.name == 'qe_comment')]
    //         .stringValue,
    //
    //     ///F
    //     'q59': fields[fields.indexWhere((e) => e.name == 'q56')].stringValue,
    //     'q60': fields[fields.indexWhere((e) => e.name == 'q60')].stringValue,
    //     'q61': fields[fields.indexWhere((e) => e.name == 'q61')].stringValue,
    //     'q62': fields[fields.indexWhere((e) => e.name == 'q62')].stringValue,
    //     'q63': fields[fields.indexWhere((e) => e.name == 'q63')].stringValue,
    //     'q64': fields[fields.indexWhere((e) => e.name == 'q64')].stringValue,
    //     'q65': fields[fields.indexWhere((e) => e.name == 'q65')].stringValue,
    //     'q66': fields[fields.indexWhere((e) => e.name == 'q66')].stringValue,
    //     'q67': fields[fields.indexWhere((e) => e.name == 'q67')].stringValue,
    //     'q68': fields[fields.indexWhere((e) => e.name == 'q68')].stringValue,
    //     'q69': fields[fields.indexWhere((e) => e.name == 'q69')].stringValue,
    //     'q70': fields[fields.indexWhere((e) => e.name == 'q70')].stringValue,
    //     'qf_comment': fields[fields.indexWhere((e) => e.name == 'qf_comment')]
    //         .stringValue,
    //
    //     ///G
    //     'q71': fields[fields.indexWhere((e) => e.name == 'q71')].stringValue,
    //     'q72': fields[fields.indexWhere((e) => e.name == 'q72')].stringValue,
    //     'q73': fields[fields.indexWhere((e) => e.name == 'q73')].stringValue,
    //     'q74': fields[fields.indexWhere((e) => e.name == 'q74')].stringValue,
    //     'qg_comment': fields[fields.indexWhere((e) => e.name == 'qg_comment')]
    //         .stringValue,
    //
    //     ///H
    //     'q75': fields[fields.indexWhere((e) => e.name == 'q75')].stringValue,
    //     'q76': fields[fields.indexWhere((e) => e.name == 'q76')].stringValue,
    //     'q77': fields[fields.indexWhere((e) => e.name == 'q77')].stringValue,
    //     'q78': fields[fields.indexWhere((e) => e.name == 'q78')].stringValue,
    //     'qh_comment': fields[fields.indexWhere((e) => e.name == 'qh_comment')]
    //         .stringValue,
    //
    //     ///I
    //     'q79': fields[fields.indexWhere((e) => e.name == 'q79')].stringValue,
    //     'q80': fields[fields.indexWhere((e) => e.name == 'q80')].stringValue,
    //     'q81': fields[fields.indexWhere((e) => e.name == 'q81')].stringValue,
    //     'q82': fields[fields.indexWhere((e) => e.name == 'q82')].stringValue,
    //     'q83': fields[fields.indexWhere((e) => e.name == 'q83')].stringValue,
    //     'q84': fields[fields.indexWhere((e) => e.name == 'q84')].stringValue,
    //     'q85': fields[fields.indexWhere((e) => e.name == 'q85')].stringValue,
    //     'q86': fields[fields.indexWhere((e) => e.name == 'q86')].stringValue,
    //     'qi_comment': fields[fields.indexWhere((e) => e.name == 'qi_comment')]
    //         .stringValue,
    //
    //     ///J
    //     'q87': fields[fields.indexWhere((e) => e.name == 'q87')].stringValue,
    //     'q88': fields[fields.indexWhere((e) => e.name == 'q88')].stringValue,
    //     'q89': fields[fields.indexWhere((e) => e.name == 'q89')].stringValue,
    //     'q90': fields[fields.indexWhere((e) => e.name == 'q90')].stringValue,
    //     'q91': fields[fields.indexWhere((e) => e.name == 'q91')].stringValue,
    //     'q92': fields[fields.indexWhere((e) => e.name == 'q92')].stringValue,
    //     'q93': fields[fields.indexWhere((e) => e.name == 'q93')].stringValue,
    //     'qj_comment': fields[fields.indexWhere((e) => e.name == 'qj_comment')]
    //         .stringValue,
    //
    //     ///Additional Comment
    //     'additional_comment':
    //     fields[fields.indexWhere((e) => e.name == 'additional_comment')]
    //         .stringValue,
    //
    //     ///RESULT
    //     'result':
    //     fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
    //     'evaluator_result':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_result')]
    //         .stringValue,
    //     'trainee_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'trainee_sig_date')]
    //         .stringValue,
    //     'purser_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'purser_sig_date')]
    //         .stringValue,
    //     'evaluator_sig_date':
    //     fields[fields.indexWhere((e) => e.name == 'evaluator_sig_date')]
    //         .stringValue,
    //   };
    // } else {
    //   return {};
    // }
    // };
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
