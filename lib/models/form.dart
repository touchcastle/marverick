import 'package:flutter/cupertino.dart';
import 'package:marverick/models/field.dart';
import 'dart:typed_data';

enum FormType {
  loe,
  lineCheck,
  sample,
}

enum FormStatus { working, completed, pending }

class Form extends ChangeNotifier {
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
  List<String>? sectionLabel;
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
    this.sectionLabel,
    this.formLabelInfoField1,
    this.formLabelInfoField2,
  });

  int allRequired() => fields.where((c) => c.mandatory).toList().length;
  int filledRequired() => fields
      .where(
        (c) =>
            c.mandatory &&
                ((c.type == FieldType.radio ||
                        c.type == FieldType.string ||
                        c.type == FieldType.date) &&
                    c.stringValue != '') ||
            (c.type == FieldType.signature &&
                c.signature != null &&
                c.signature!.length > 0) ||
            (c.type == FieldType.int && c.intValue >= 0),
      )
      .toList()
      .length;

  double percentFilled() {
    int allRequired = fields.where((c) => c.mandatory).toList().length;
    int filledRequired = fields
        .where(
          (c) =>
              c.mandatory &&
                  ((c.type == FieldType.radio ||
                          c.type == FieldType.string ||
                          c.type == FieldType.date) &&
                      c.stringValue != '') ||
              (c.type == FieldType.signature &&
                  c.signature != null &&
                  c.signature!.length > 0) ||
              (c.type == FieldType.int && c.intValue >= 0),
        )
        .toList()
        .length;
    double percent = (filledRequired / allRequired) * 100;
    return percent;
  }

  // factory Form.fromJson(dynamic json) {
  //   return Form(
  //     "${json['pilot_name']}",
  //     "${json['pilot_rank']}",
  //   );
  // }

  // Method to make GET parameters.
  Map<String, dynamic> lineCheckToMap() => {
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
        'pilot_rank': fields[fields.indexWhere((e) => e.name == 'pilot_rank')]
            .stringValue,
        'pilot_id':
            fields[fields.indexWhere((e) => e.name == 'pilot_id')].stringValue,
        'pilot_license_no':
            fields[fields.indexWhere((e) => e.name == 'pilot_license_no')]
                .stringValue,
        'pilot_name': fields[fields.indexWhere((e) => e.name == 'pilot_name')]
            .stringValue,

        //Examiner info.
        'examiner_rank':
            fields[fields.indexWhere((e) => e.name == 'examiner_rank')]
                .stringValue,
        'examiner_id': fields[fields.indexWhere((e) => e.name == 'examiner_id')]
            .stringValue,
        'examiner_license_no':
            fields[fields.indexWhere((e) => e.name == 'examiner_license_no')]
                .stringValue,
        'examiner_name':
            fields[fields.indexWhere((e) => e.name == 'examiner_name')]
                .stringValue,

        //Check type
        'type_of_check':
            fields[fields.indexWhere((e) => e.name == 'type_of_check')]
                .stringValue,
        'other_type': fields[fields.indexWhere((e) => e.name == 'other_type')]
            .stringValue,

        //Sector#1
        'date_1':
            fields[fields.indexWhere((e) => e.name == 'date_1')].stringValue,
        'ac_type_1':
            fields[fields.indexWhere((e) => e.name == 'ac_type_1')].stringValue,
        'ac_reg_1':
            fields[fields.indexWhere((e) => e.name == 'ac_reg_1')].stringValue,
        'flt_no_1':
            fields[fields.indexWhere((e) => e.name == 'flt_no_1')].stringValue,
        'from_1':
            fields[fields.indexWhere((e) => e.name == 'from_1')].stringValue,
        'to_1': fields[fields.indexWhere((e) => e.name == 'to_1')].stringValue,
        'duty_1':
            fields[fields.indexWhere((e) => e.name == 'duty_1')].stringValue,

        //Sector#2
        'date_2':
            fields[fields.indexWhere((e) => e.name == 'date_2')].stringValue,
        'ac_type_2':
            fields[fields.indexWhere((e) => e.name == 'ac_type_2')].stringValue,
        'ac_reg_2':
            fields[fields.indexWhere((e) => e.name == 'ac_reg_2')].stringValue,
        'flt_no_2':
            fields[fields.indexWhere((e) => e.name == 'flt_no_2')].stringValue,
        'from_2':
            fields[fields.indexWhere((e) => e.name == 'from_2')].stringValue,
        'to_2': fields[fields.indexWhere((e) => e.name == 'to_2')].stringValue,
        'duty_2':
            fields[fields.indexWhere((e) => e.name == 'duty_2')].stringValue,

        //Grading & Comment
        //A
        'a_1': fields[fields.indexWhere((e) => e.name == 'a_1')].stringValue,
        'a_2': fields[fields.indexWhere((e) => e.name == 'a_2')].stringValue,
        'a_3': fields[fields.indexWhere((e) => e.name == 'a_3')].stringValue,
        'a_4': fields[fields.indexWhere((e) => e.name == 'a_4')].stringValue,
        'a_5': fields[fields.indexWhere((e) => e.name == 'a_5')].stringValue,
        'a_6': fields[fields.indexWhere((e) => e.name == 'a_6')].stringValue,
        'a_7': fields[fields.indexWhere((e) => e.name == 'a_7')].stringValue,
        'a_comment':
            fields[fields.indexWhere((e) => e.name == 'a_comment')].stringValue,
        //B
        'b_8': fields[fields.indexWhere((e) => e.name == 'b_8')].stringValue,
        'b_9': fields[fields.indexWhere((e) => e.name == 'b_9')].stringValue,
        'b_10': fields[fields.indexWhere((e) => e.name == 'b_10')].stringValue,
        'b_11': fields[fields.indexWhere((e) => e.name == 'b_11')].stringValue,
        'b_12': fields[fields.indexWhere((e) => e.name == 'b_12')].stringValue,
        'b_13': fields[fields.indexWhere((e) => e.name == 'b_13')].stringValue,
        'b_comment':
            fields[fields.indexWhere((e) => e.name == 'b_comment')].stringValue,
        //C
        'c_14': fields[fields.indexWhere((e) => e.name == 'c_14')].stringValue,
        'c_15': fields[fields.indexWhere((e) => e.name == 'c_15')].stringValue,
        'c_16': fields[fields.indexWhere((e) => e.name == 'c_16')].stringValue,
        'c_17': fields[fields.indexWhere((e) => e.name == 'c_17')].stringValue,
        'c_18': fields[fields.indexWhere((e) => e.name == 'c_18')].stringValue,
        'c_comment':
            fields[fields.indexWhere((e) => e.name == 'c_comment')].stringValue,
        //D
        'd_19': fields[fields.indexWhere((e) => e.name == 'd_19')].stringValue,
        'd_20': fields[fields.indexWhere((e) => e.name == 'd_20')].stringValue,
        'd_21': fields[fields.indexWhere((e) => e.name == 'd_21')].stringValue,
        'd_22': fields[fields.indexWhere((e) => e.name == 'd_22')].stringValue,
        'd_23': fields[fields.indexWhere((e) => e.name == 'd_23')].stringValue,
        'd_24': fields[fields.indexWhere((e) => e.name == 'd_24')].stringValue,
        'd_25': fields[fields.indexWhere((e) => e.name == 'd_25')].stringValue,
        'd_26': fields[fields.indexWhere((e) => e.name == 'd_26')].stringValue,
        'd_27': fields[fields.indexWhere((e) => e.name == 'd_27')].stringValue,
        'd_28': fields[fields.indexWhere((e) => e.name == 'd_28')].stringValue,
        'd_comment':
            fields[fields.indexWhere((e) => e.name == 'd_comment')].stringValue,
        //E
        'e_29': fields[fields.indexWhere((e) => e.name == 'e_29')].stringValue,
        'e_30': fields[fields.indexWhere((e) => e.name == 'e_30')].stringValue,
        'e_31': fields[fields.indexWhere((e) => e.name == 'e_31')].stringValue,
        'e_32': fields[fields.indexWhere((e) => e.name == 'e_32')].stringValue,
        'e_33': fields[fields.indexWhere((e) => e.name == 'e_33')].stringValue,
        'e_34': fields[fields.indexWhere((e) => e.name == 'e_34')].stringValue,
        'e_comment':
            fields[fields.indexWhere((e) => e.name == 'e_comment')].stringValue,
        //BRIEFING
        'brief_1':
            fields[fields.indexWhere((e) => e.name == 'brief_1')].stringValue,
        'brief_2':
            fields[fields.indexWhere((e) => e.name == 'brief_2')].stringValue,
        'brief_3':
            fields[fields.indexWhere((e) => e.name == 'brief_3')].stringValue,
        'brief_4':
            fields[fields.indexWhere((e) => e.name == 'brief_4')].stringValue,
        'brief_5':
            fields[fields.indexWhere((e) => e.name == 'brief_5')].stringValue,
        'brief_comment':
            fields[fields.indexWhere((e) => e.name == 'brief_comment')]
                .stringValue,
        //COMPETENCY
        'comp_pro':
            fields[fields.indexWhere((e) => e.name == 'comp_pro')].stringValue,
        'comp_com':
            fields[fields.indexWhere((e) => e.name == 'comp_com')].stringValue,
        'comp_fpa':
            fields[fields.indexWhere((e) => e.name == 'comp_fpa')].stringValue,
        'comp_fpm':
            fields[fields.indexWhere((e) => e.name == 'comp_fpm')].stringValue,
        'comp_kno':
            fields[fields.indexWhere((e) => e.name == 'comp_kno')].stringValue,
        'comp_ltw':
            fields[fields.indexWhere((e) => e.name == 'comp_ltw')].stringValue,
        'comp_psd':
            fields[fields.indexWhere((e) => e.name == 'comp_psd')].stringValue,
        'comp_saw':
            fields[fields.indexWhere((e) => e.name == 'comp_saw')].stringValue,
        'comp_wlm':
            fields[fields.indexWhere((e) => e.name == 'comp_wlm')].stringValue,
        'general_comment':
            fields[fields.indexWhere((e) => e.name == 'general_comment')]
                .stringValue,
        //RESULT
        'result':
            fields[fields.indexWhere((e) => e.name == 'result')].stringValue,
        'competent_level':
            fields[fields.indexWhere((e) => e.name == 'competent_level')]
                .stringValue,
        'result_comment':
            fields[fields.indexWhere((e) => e.name == 'result_comment')]
                .stringValue,

        'pilot_sig_date':
            fields[fields.indexWhere((e) => e.name == 'pilot_sig_date')]
                .stringValue,
        'examiner_sig_date':
            fields[fields.indexWhere((e) => e.name == 'examiner_sig_date')]
                .stringValue,
      };

  void validate() {
    if (type == FormType.lineCheck) {
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
  }
}
