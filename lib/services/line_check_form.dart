// lib/services/form_definitions/line_check_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:marverick/models/form.dart' as f;
import 'package:marverick/models/field.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/utils/constants.dart';

class LineCheckForm {
  static const _uuid = Uuid();

  static f.Form init() {
    final timeStamp = DateTime.now();
    final gradeList = ['1', '2', '3', '4', '5', 'N/O'];
    final boolList = ['YES', 'NO'];
    final gradePosX = [307.0, 324.0, 342.0, 359.0, 377.0, 396.0];
    final competentPosX = [165.0, 183.0, 201.0, 219.0, 237.0, 256.0];
    const gradeCommentMaxLen = 180;

    return f.Form(
      type: f.FormType.lineCheck,
      formName: 'Line Check',
      createDateTime: timeStamp,
      createBy: Authen.user != null ? Authen.user.email : '',
      id: _uuid.v1(),
      filePath: 'forms/linecheck.pdf',
      dbTable: kLineCheckTable,
      fontSize: 10,
      sectionLabel: [
        'Personal Detail',
        'Check Detail',
        'Grading',
        'Briefing Items',
        'Competency Assessment and Comments',
        'Result',
        'Signature',
      ],
      gradeSectionLabel: [
        'PRE-FLIGHT PREPARATION AND ENGINE START',
        'TAXI AND TAKEOFF',
        'CLIMB and CRUISE',
        'DESCENT / APPROACH AND LANDING',
        'NON-TECHNICAL',
      ],
      formLabel: 'Line Check',
      formLabelInfoField1: 'pilot_rank',
      formLabelInfoField2: 'pilot_name',
      dateFormat: 'dd/MM/yyyy',
      fields: [
        //----------------------------------------------------------------------
        // PILOT
        //----------------------------------------------------------------------
        Field(
          name: 'pilot_rank',
          label: 'Pilot Rank',
          type: FieldType.radio,
          listValue: ['Capt.', 'FO.'],
          intValue: kInitChoice,
          section: 1,
          subSection: 1,
          page: 1,
          posXList: [152, 178],
          posYList: [100, 100],
        ),
        Field(
          name: 'pilot_name',
          label: 'Pilot Name',
          type: FieldType.string,
          section: 1,
          subSection: 1,
          posX: 200,
          posY: 102,
        ),
        Field(
          name: 'pilot_license_no',
          label: 'Pilot License No.',
          type: FieldType.string,
          section: 1,
          subSection: 1,
          posX: 152,
          posY: 127,
        ),
        Field(
          name: 'pilot_id',
          label: 'Pilot Staff ID No.(xxxx)',
          type: FieldType.string,
          section: 1,
          subSection: 1,
          maxLength: 4,
          keyboardType: TextInputType.number,
          posX: 167,
          posY: 149,
        ),
        //----------------------------------------------------------------------
        // EXAMINER
        //----------------------------------------------------------------------
        Field(
          name: 'examiner_rank',
          label: 'Examiner Rank',
          type: FieldType.radio,
          listValue: ['DCP', 'FI-A', 'SV'],
          intValue: kInitChoice,
          section: 1,
          subSection: 2,
          page: 1,
          posXList: [360, 385, 410],
          posYList: [100, 100, 100],
        ),
        Field(
          name: 'examiner_name',
          label: 'Examiner Name',
          type: FieldType.string,
          section: 1,
          subSection: 2,
          posX: 430,
          posY: 102,
        ),
        Field(
          name: 'examiner_license_no',
          label: 'Examiner License / Certificate No.',
          type: FieldType.string,
          section: 1,
          subSection: 2,
          posX: 360,
          posY: 127,
        ),
        Field(
          name: 'examiner_id',
          label: 'Examiner Staff ID No.(xxxx)',
          type: FieldType.string,
          section: 1,
          subSection: 2,
          maxLength: 4,
          keyboardType: TextInputType.number,
          posX: 375,
          posY: 149,
        ),
        //----------------------------------------------------------------------
        // CHECK DETAILS
        //----------------------------------------------------------------------
        Field(
          name: 'type_of_check',
          label: 'Type Of Check',
          type: FieldType.radio,
          listValue: ['Initial', 'Annual', 'Recency', 'Requalification', 'Other'],
          intValue: kInitChoice,
          section: 2,
          subSection: 1,
          page: 1,
          posXList: [45, 45, 45, 45, 45],
          posYList: [195, 212, 229, 245, 262],
        ),
        Field(
          name: 'other_type',
          label: 'Other(if selected)',
          type: FieldType.string,
          section: 2,
          subSection: 1,
          isMandatory: false,
          posX: 78,
          posY: 262,
        ),
        // Sector 1
        Field(
          name: 'ac_type_1',
          label: 'Sector 1 A/C Type',
          type: FieldType.radio,
          listValue: ['A320', 'A321'],
          intValue: kInitChoice,
          page: 1,
          section: 2,
          subSection: 2,
          posXList: [345, 381],
          posYList: [179, 179],
        ),
        Field(
          name: 'ac_reg_1',
          label: 'Sector 1 Registration (HS-___)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 2,
          maxLength: 3,
          minLength: 3,
          posX: 370,
          posY: 246,
        ),
        Field(
          name: 'date_1',
          label: 'Sector 1 Date',
          type: FieldType.date,
          page: 1,
          section: 2,
          subSection: 2,
          keyboardType: TextInputType.datetime,
          stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          dateTimeValue: DateTime.now(),
          posX: 345,
          posY: 197,
        ),
        Field(
          name: 'flt_no_1',
          label: 'Sector 1 Flight No. (VZ___)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 2,
          maxLength: 4,
          keyboardType: TextInputType.number,
          posX: 363,
          posY: 212,
        ),
        Field(
          name: 'from_1',
          label: 'Sector 1 From (ICAO)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 2,
          maxLength: 4,
          minLength: 4,
          stringValue: 'VTBS',
          posX: 345,
          posY: 229,
        ),
        Field(
          name: 'to_1',
          label: 'Sector 1 To (ICAO)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 2,
          maxLength: 4,
          minLength: 4,
          posX: 378,
          posY: 229,
        ),
        Field(
          name: 'duty_1',
          label: 'Sector 1 Duty',
          type: FieldType.radio,
          listValue: ['PF', 'PM'],
          intValue: kInitChoice,
          page: 1,
          section: 2,
          subSection: 2,
          posXList: [353, 380],
          posYList: [262, 262],
        ),
        // Sector 2
        Field(
          name: 'ac_type_2',
          label: 'Sector 2 A/C Type',
          type: FieldType.radio,
          listValue: ['A320', 'A321'],
          intValue: kInitChoice,
          page: 1,
          section: 2,
          subSection: 3,
          posXList: [468, 504],
          posYList: [179, 179],
        ),
        Field(
          name: 'ac_reg_2',
          label: 'Sector 2 Registration (HS-___)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 3,
          maxLength: 3,
          minLength: 3,
          posX: 493,
          posY: 246,
        ),
        Field(
          name: 'date_2',
          label: 'Sector 2 Date',
          type: FieldType.date,
          keyboardType: TextInputType.datetime,
          page: 1,
          section: 2,
          subSection: 3,
          stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          dateTimeValue: DateTime.now(),
          posX: 468,
          posY: 197,
        ),
        Field(
          name: 'flt_no_2',
          label: 'Sector 2 Flight No. (VZ___)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 3,
          maxLength: 4,
          keyboardType: TextInputType.number,
          posX: 486,
          posY: 212,
        ),
        Field(
          name: 'from_2',
          label: 'Sector 2 From (ICAO)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 3,
          maxLength: 4,
          minLength: 4,
          posX: 468,
          posY: 229,
        ),
        Field(
          name: 'to_2',
          label: 'Sector 2 To (ICAO)',
          type: FieldType.string,
          page: 1,
          section: 2,
          subSection: 3,
          maxLength: 4,
          minLength: 4,
          stringValue: 'VTBS',
          posX: 501,
          posY: 229,
        ),
        Field(
          name: 'duty_2',
          label: 'Sector 2 Duty',
          type: FieldType.radio,
          listValue: ['PF', 'PM'],
          intValue: kInitChoice,
          page: 1,
          section: 2,
          subSection: 3,
          posXList: [476, 503],
          posYList: [262, 262],
        ),
        //----------------------------------------------------------------------
        // GRADING — Section A
        //----------------------------------------------------------------------
        Field(name: 'a_1', label: 'Flight documents, Security check, Flight crew and Cabin crew briefing', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 1, gradeSection: 1, posXList: gradePosX, posYList: [360, 360, 360, 360, 360, 360]),
        Field(name: 'a_2', label: 'Fuel policy / FMGS preparation / X-check', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 1, gradeSection: 1, posXList: gradePosX, posYList: [373, 373, 373, 373, 373, 373]),
        Field(name: 'a_3', label: 'Aircraft status / MEL', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 1, gradeSection: 1, posXList: gradePosX, posYList: [386, 386, 386, 386, 386, 386]),
        Field(name: 'a_4', label: 'Aircraft safety inspection (Exterior and Internal)', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 1, gradeSection: 1, posXList: gradePosX, posYList: [399, 399, 399, 399, 399, 399]),
        Field(name: 'a_5', label: 'Load sheet / Takeoff performance calculation', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 1, gradeSection: 1, posXList: gradePosX, posYList: [412, 412, 412, 412, 412, 412]),
        Field(name: 'a_6', label: 'Takeoff briefing / TEM / NAVAIDS setting', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 1, gradeSection: 1, posXList: gradePosX, posYList: [425, 425, 425, 425, 425, 425]),
        Field(name: 'a_7', label: 'Timely Engine Start / Monitoring Engine Start', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 1, gradeSection: 1, posXList: gradePosX, posYList: [439, 439, 439, 439, 439, 439]),
        Field(name: 'a_comment', label: 'Comment', type: FieldType.string, page: 1, section: 3, subSection: 1, gradeSection: 1, isMandatory: false, maxLength: gradeCommentMaxLen, posX: 410, posY: 360),
        //----------------------------------------------------------------------
        // GRADING — Section B
        //----------------------------------------------------------------------
        Field(name: 'b_8',  label: 'Taxi', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 2, gradeSection: 2, posXList: gradePosX, posYList: [467, 467, 467, 467, 467, 467]),
        Field(name: 'b_9',  label: 'Normal Takeoff', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 2, gradeSection: 2, posXList: gradePosX, posYList: [480, 480, 480, 480, 480, 480]),
        Field(name: 'b_10', label: 'Crosswind Takeoff', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 2, gradeSection: 2, posXList: gradePosX, posYList: [493, 493, 493, 493, 493, 493]),
        Field(name: 'b_11', label: 'Noise Abatement Procedure', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 2, gradeSection: 2, posXList: gradePosX, posYList: [506, 506, 506, 506, 506, 506]),
        Field(name: 'b_12', label: 'ATC Communication', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 2, gradeSection: 2, posXList: gradePosX, posYList: [519, 519, 519, 519, 519, 519]),
        Field(name: 'b_13', label: 'After takeoff checks', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 1, section: 3, subSection: 2, gradeSection: 2, posXList: gradePosX, posYList: [532, 532, 532, 532, 532, 532]),
        Field(name: 'b_comment', label: 'Comment', type: FieldType.string, page: 1, section: 3, subSection: 2, gradeSection: 2, isMandatory: false, maxLength: gradeCommentMaxLen, posX: 410, posY: 467),
        //----------------------------------------------------------------------
        // GRADING — Section C
        //----------------------------------------------------------------------
        Field(name: 'c_14', label: 'Climb', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 3, gradeSection: 3, posXList: gradePosX, posYList: [95, 95, 95, 95, 95, 95]),
        Field(name: 'c_15', label: 'Cruise', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 3, gradeSection: 3, posXList: gradePosX, posYList: [108, 108, 108, 108, 108, 108]),
        Field(name: 'c_16', label: 'ETOPS', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 3, gradeSection: 3, posXList: gradePosX, posYList: [121, 121, 121, 121, 121, 121]),
        Field(name: 'c_17', label: 'Fuel management', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 3, gradeSection: 3, posXList: gradePosX, posYList: [134, 134, 134, 134, 134, 134]),
        Field(name: 'c_18', label: 'Descent / Approach preparation', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 3, gradeSection: 3, posXList: gradePosX, posYList: [147, 147, 147, 147, 147, 147]),
        Field(name: 'c_comment', label: 'Comment', type: FieldType.string, page: 2, section: 3, subSection: 3, gradeSection: 3, isMandatory: false, maxLength: gradeCommentMaxLen, posX: 410, posY: 95),
        //----------------------------------------------------------------------
        // GRADING — Section D
        //----------------------------------------------------------------------
        Field(name: 'd_19', label: 'Approach briefing / NAVAIDS setting / TEM', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [175, 175, 175, 175, 175, 175]),
        Field(name: 'd_20', label: 'Instrument approach', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [188, 188, 188, 188, 188, 188]),
        Field(name: 'd_21', label: 'Visual approach', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [201, 201, 201, 201, 201, 201]),
        Field(name: 'd_22', label: 'Circling approach', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [214, 214, 214, 214, 214, 214]),
        Field(name: 'd_23', label: 'Crosswind approach and landing', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [227, 227, 227, 227, 227, 227]),
        Field(name: 'd_24', label: 'Normal landing', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [240, 240, 240, 240, 240, 240]),
        Field(name: 'd_25', label: 'Go around', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [253, 253, 253, 253, 253, 253]),
        Field(name: 'd_26', label: 'After landing checks', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [266, 266, 266, 266, 266, 266]),
        Field(name: 'd_27', label: 'Taxi in', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [279, 279, 279, 279, 279, 279]),
        Field(name: 'd_28', label: 'Shutdown procedure', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 4, gradeSection: 4, posXList: gradePosX, posYList: [292, 292, 292, 292, 292, 292]),
        Field(name: 'd_comment', label: 'Comment', type: FieldType.string, page: 2, section: 3, subSection: 4, gradeSection: 4, isMandatory: false, maxLength: gradeCommentMaxLen, posX: 410, posY: 175),
        //----------------------------------------------------------------------
        // GRADING — Section E (Non-Technical)
        //----------------------------------------------------------------------
        Field(name: 'e_29', label: 'Communication', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 5, gradeSection: 5, posXList: gradePosX, posYList: [320, 320, 320, 320, 320, 320]),
        Field(name: 'e_30', label: 'Leadership and Teamwork', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 5, gradeSection: 5, posXList: gradePosX, posYList: [333, 333, 333, 333, 333, 333]),
        Field(name: 'e_31', label: 'Problem Solving and Decision Making', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 5, gradeSection: 5, posXList: gradePosX, posYList: [346, 346, 346, 346, 346, 346]),
        Field(name: 'e_32', label: 'Situational Awareness', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 5, gradeSection: 5, posXList: gradePosX, posYList: [359, 359, 359, 359, 359, 359]),
        Field(name: 'e_33', label: 'Workload Management', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 5, gradeSection: 5, posXList: gradePosX, posYList: [372, 372, 372, 372, 372, 372]),
        Field(name: 'e_34', label: 'Flight Path Management (Manual)', type: FieldType.radio, listValue: gradeList, intValue: kInitChoice, page: 2, section: 3, subSection: 5, gradeSection: 5, posXList: gradePosX, posYList: [385, 385, 385, 385, 385, 385]),
        Field(name: 'e_comment', label: 'Comment', type: FieldType.string, page: 2, section: 3, subSection: 5, gradeSection: 5, isMandatory: false, maxLength: gradeCommentMaxLen, posX: 410, posY: 320),
        //----------------------------------------------------------------------
        // BRIEFING ITEMS
        //----------------------------------------------------------------------
        Field(name: 'brief_1', label: 'Briefing Item 1', type: FieldType.radio, listValue: boolList, intValue: kInitChoice, page: 2, section: 4, subSection: 1, posXList: [45, 65], posYList: [430, 430]),
        Field(name: 'brief_2', label: 'Briefing Item 2', type: FieldType.radio, listValue: boolList, intValue: kInitChoice, page: 2, section: 4, subSection: 1, posXList: [45, 65], posYList: [443, 443]),
        Field(name: 'brief_3', label: 'Briefing Item 3', type: FieldType.radio, listValue: boolList, intValue: kInitChoice, page: 2, section: 4, subSection: 1, posXList: [45, 65], posYList: [456, 456]),
        Field(name: 'brief_4', label: 'Briefing Item 4', type: FieldType.radio, listValue: boolList, intValue: kInitChoice, page: 2, section: 4, subSection: 1, posXList: [45, 65], posYList: [469, 469]),
        Field(name: 'brief_5', label: 'Briefing Item 5', type: FieldType.radio, listValue: boolList, intValue: kInitChoice, page: 2, section: 4, subSection: 1, posXList: [45, 65], posYList: [482, 482]),
        Field(name: 'brief_comment', label: 'Briefing Comment', type: FieldType.string, page: 2, section: 4, subSection: 1, isMandatory: false, posX: 45, posY: 495),
        //----------------------------------------------------------------------
        // COMPETENCY ASSESSMENT
        //----------------------------------------------------------------------
        Field(name: 'comp_pro', label: 'Procedures', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [95, 95, 95, 95, 95, 95]),
        Field(name: 'comp_com', label: 'Communication', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [108, 108, 108, 108, 108, 108]),
        Field(name: 'comp_fpa', label: 'Flight Path Automation', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [121, 121, 121, 121, 121, 121]),
        Field(name: 'comp_fpm', label: 'Flight Path Manual Control', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [134, 134, 134, 134, 134, 134]),
        Field(name: 'comp_kno', label: 'Knowledge', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [147, 147, 147, 147, 147, 147]),
        Field(name: 'comp_ltw', label: 'Leadership and Teamwork', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [160, 160, 160, 160, 160, 160]),
        Field(name: 'comp_psd', label: 'Problem Solving and Decision Making', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [173, 173, 173, 173, 173, 173]),
        Field(name: 'comp_saw', label: 'Situational Awareness', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [186, 186, 186, 186, 186, 186]),
        Field(name: 'comp_wlm', label: 'Workload Management', type: FieldType.radio, listValue: ['C', 'NI', 'NC'], intValue: kInitChoice, page: 3, section: 5, subSection: 1, posXList: competentPosX, posYList: [199, 199, 199, 199, 199, 199]),
        Field(name: 'general_comment', label: 'General Comment', type: FieldType.string, page: 3, section: 5, subSection: 1, isMandatory: false, posX: 45, posY: 215),
        //----------------------------------------------------------------------
        // RESULT
        //----------------------------------------------------------------------
        Field(name: 'result', label: 'Result', type: FieldType.radio, listValue: ['SATISFACTORY', 'UNSATISFACTORY'], intValue: kInitChoice, page: 3, section: 6, subSection: 1, posXList: [45, 150], posYList: [270, 270]),
        Field(name: 'competent_level', label: 'Competent Level', type: FieldType.radio, listValue: ['COMPETENT', 'NOT YET COMPETENT'], intValue: kInitChoice, page: 3, section: 6, subSection: 1, posXList: [45, 130], posYList: [285, 285]),
        Field(name: 'result_comment', label: 'Result Comment', type: FieldType.string, page: 3, section: 6, subSection: 1, isMandatory: false, posX: 45, posY: 300),
        //----------------------------------------------------------------------
        // SIGNATURES
        //----------------------------------------------------------------------
        Field(name: 'pilot_sig_date', label: 'Pilot Signature Date', type: FieldType.date, keyboardType: TextInputType.datetime, page: 3, section: 7, subSection: 1, stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()), dateTimeValue: DateTime.now(), posX: 100, posY: 380),
        Field(name: 'examiner_sig_date', label: 'Examiner Signature Date', type: FieldType.date, keyboardType: TextInputType.datetime, page: 3, section: 7, subSection: 2, stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()), dateTimeValue: DateTime.now(), posX: 380, posY: 380),
        Field(name: 'pilot_sig', label: 'Pilot Signature', type: FieldType.signature, page: 3, section: 7, subSection: 1, sigWidth: 150, sigMaxHeight: 50, posX: 100, posY: 360),
        Field(name: 'examiner_sig', label: 'Examiner Signature', type: FieldType.signature, page: 3, section: 7, subSection: 2, sigWidth: 150, sigMaxHeight: 50, posX: 380, posY: 360),
      ],
    );
  }
}
