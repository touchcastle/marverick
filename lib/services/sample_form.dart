// lib/services/form_definitions/sample_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/models/field.dart';

class SampleForm {
  static const _uuid = Uuid();

  static f.Form init() {
    final timeStamp = DateTime.now();

    return f.Form(
      type: f.FormType.sample,
      formName: 'Signature Verification',
      createDateTime: timeStamp,
      createBy: 'sample',
      id: _uuid.v1(),
      filePath: 'forms/sample.pdf',
      fontSize: 13,
      formLabel: 'Signature Verification',
      formLabelInfoField1: 'name',
      dbTable: '',
      sectionLabel: ['Main'],
      fields: [
        Field(
          name: 'name',
          label: 'Applicant Full Name',
          type: FieldType.string,
          posX: 210,
          posY: 265,
        ),
        Field(
          name: 'gender',
          label: 'Gender',
          type: FieldType.string,
          posX: 150,
          posY: 288,
        ),
        Field(
          name: 'dob',
          label: 'Date of birth',
          type: FieldType.date,
          keyboardType: TextInputType.datetime,
          stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          dateTimeValue: DateTime.now(),
          posX: 292,
          posY: 310,
        ),
        Field(
          name: 'email',
          label: 'Email',
          type: FieldType.string,
          posX: 140,
          posY: 333,
        ),
        Field(
          name: 'sig',
          label: 'Signature',
          type: FieldType.signature,
          sigWidth: 100,
          sigMaxHeight: 40,
          posX: 180,
          posY: 390,
        ),
        Field(
          name: 'sig_date',
          label: 'Date',
          type: FieldType.date,
          keyboardType: TextInputType.datetime,
          dateTimeValue: DateTime.now(),
          stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          posX: 230,
          posY: 410,
        ),
      ],
    );
  }
}
