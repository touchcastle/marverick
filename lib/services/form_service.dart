import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/models/field.dart';
import 'package:marverick/services/pdf.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/services/database.dart';
import 'package:marverick/ui/views/input.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/utils/utils.dart';

enum ErrorType {
  success,
  missingRequired,
  noInternet,
  other,
}

class FormService extends ChangeNotifier {
  Authen authen;
  Pdf pdf;

  List<f.Form> forms = [];

  FormService({required this.authen, required this.pdf});

  static var uuid = Uuid();

  int pendingCount = 0;
  int draftCount = 0;

  void newForm(BuildContext c, f.Form form) {
    forms.add(form);
    countPending();
    notifyListeners();
    Navigator.of(c).push(PageRouteBuilder(
        settings: RouteSettings(name: kInputPageName),
        pageBuilder: (_, __, ___) => InputScreen(
              form: forms[forms.length - 1],
            )));
  }

  void moveToComplted(f.Form form) {
    int _i = forms.indexWhere((e) => e.id == form.id);
    forms[_i].status = f.FormStatus.completed;
    save(form);
    countPending();
    notifyListeners();
  }

  void moveToPending(f.Form form) {
    int _i = forms.indexWhere((e) => e.id == form.id);
    forms[_i].status = f.FormStatus.pending;
    save(form);
    countPending();
    notifyListeners();
  }

  void countPending() {
    pendingCount =
        forms.where((c) => c.status == f.FormStatus.pending).toList().length;
    draftCount =
        forms.where((c) => c.status == f.FormStatus.working).toList().length;
  }

  ///===========================================================================
  ///TO GOOGLE SHEET
  ///===========================================================================
  // Google App Script Web URL.
  // late Uri sheetUrl = Uri.parse(kLineChekSheetUrl);

  // Success Status Message
  var storage = FirebaseStorage.instance;
  String? downloadUrl;

  String formName(f.FormType type) {
    if (type == f.FormType.lineCheck) {
      return 'line_check';
    } else {
      return 'untitled';
    }
  }

  String formUrl(f.FormType type) {
    if (type == f.FormType.lineCheck) {
      return kLineChekSheetUrl;
    } else {
      return 'untitled';
    }
  }

  String pdfName(f.Form form, DateTime date) {
    if (form.type == f.FormType.lineCheck) {
      String dateText = DateFormat('yyyyMMdd').format(date);
      String pilotName = form
          .fields[form.fields.indexWhere((e) => e.name == 'pilot_name')]
          .stringValue;
      return '${formName(form.type)}_${pilotName}_$dateText.pdf';
    } else {
      return '${form.id}.pdf';
    }
  }

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [url]. On successful response, [callback] is called.
  Future submitForm(
      f.Form form, void Function(String, ErrorType) callback) async {
    downloadUrl = null;
    DateTime submitDate = DateTime.now();
    double percentCompleted;
    if (!Authen.isSample) {
      Utils.isAdmin() ? percentCompleted = 1 : percentCompleted = 99.5;
      await save(form);
      if (form.percentFilled() > percentCompleted) {
        if (await (Connectivity().checkConnectivity()) ==
            ConnectivityResult.none) {
          callback('No internet connection: Form moved to pending',
              ErrorType.noInternet);
          moveToPending(form);
        } else {
          try {
            Utils.showInProgress(true);

            //UPLOAD PDF TO GOOGLE STORAGE
            form.validate();
            String name = pdfName(form, submitDate);
            List<int> pdfAsBytes = await pdf.gen(form);
            final Directory directory =
                await path_provider.getApplicationSupportDirectory();
            String path = directory.path;
            final File file = File('$path/$name');
            await file.writeAsBytes(pdfAsBytes, flush: true);
            TaskSnapshot snapshot = await storage
                .ref()
                .child("${formName(form.type)}/${pdfName(form, submitDate)}")
                .putFile(file);
            if (snapshot.state == TaskState.success) {
              downloadUrl = await snapshot.ref.getDownloadURL();
              form.pdfUrl = downloadUrl;
            } else {
              form.pdfUrl = 'error';
            }

            //UPLOAD JSON TO GOOGLE SHEET
            await http
                .post(Uri.parse(formUrl(form.type)),
                    body: form.lineCheckToMap())
                .then((response) async {
              if (response.statusCode == 302) {
                var _url = response.headers['location'];
                await http.get(Uri.parse(_url!)).then((response) {
                  forms[forms.indexWhere((e) => e.id == form.id)]
                      .submitDateTime = submitDate;
                  moveToComplted(form);
                  callback(kStatusSuccess, ErrorType.success);
                });
              } else {
                moveToPending(form);
                callback('ERROR', ErrorType.other);
              }
            });
          } catch (e) {
            moveToPending(form);
            Utils.showInProgress(false);
            callback('ERROR: $e', ErrorType.other);
          }
        }
      } else {
        Utils.showInProgress(false);
        callback(
            'ERROR: Please fill all required field', ErrorType.missingRequired);
      }
    } else {
      ///Mockup success message
      callback(kStatusSuccess, ErrorType.success);
    }
    Utils.showInProgress(false);
  }

  ///===========================================================================
  ///DATABASE
  ///===========================================================================
  Future loadFromDatabase() async {
    forms = await LineCheckDatabase.dbLineCheckQuery();

    //Get signature from local directory as bytes
    for (int i = 0; i < forms.length; i++) {
      for (int f = 0; f < forms[i].fields.length; f++) {
        if (forms[i].fields[f].type == FieldType.signature) {
          try {
            forms[i].fields[f].signature = await _readSigFromDevice(
                '${forms[i].id}${forms[i].fields[f].name}');
          } catch (e) {
            print('read signature error: $e');
          }
        }
      }
    }
  }

  // Future _getFromSignature() async {}

  Future<String> _getFilePath(String name) async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/$name';
    return filePath;
  }

  Future _saveSigToDevice(String name, Uint8List byte) async {
    File file = File(await _getFilePath(name)); // 1
    await file.writeAsBytes(byte); // 2
  }

  Future<Uint8List> _readSigFromDevice(String name) async {
    File file = File(await _getFilePath(name));
    return await file.readAsBytes();
  }

  Future save(f.Form form, {bool showLoad = false}) async {
    if (!Authen.isSample) {
      showLoad ? Utils.showInProgress(true) : null;
      if (form.type == f.FormType.lineCheck) {
        await LineCheckDatabase.dbLineCheckInsert(form);
      }
      for (int i = 0; i < form.fields.length; i++) {
        if (form.fields[i].type == FieldType.signature) {
          await form.fields[i].convertSignature((String response) {});
          if (form.fields[i].signature != null) {
            await _saveSigToDevice(
                '${form.id}${form.fields[i].name}', form.fields[i].signature!);
          }
        }
      }
      showLoad ? Utils.showInProgress(false) : null;
      notifyListeners();
    }
  }

  void delete(f.Form form, void Function(String) callback) async {
    try {
      forms.removeWhere((e) => e.id == form.id);
      if (form.type == f.FormType.lineCheck) {
        await LineCheckDatabase.dbLineCheckDelete(form);
      }
      notifyListeners();
      callback(kStatusSuccess);
    } catch (e) {
      callback('$e');
    }
  }

  ///-------------------------------------------------------------------------
  ///SAMPLE FORM
  ///-------------------------------------------------------------------------
  static f.Form initSample() {
    DateTime timeStamp = DateTime.now();
    return f.Form(
      type: f.FormType.sample,
      formName: 'Signature Verification',
      createDateTime: timeStamp,
      createBy: 'sample',
      id: uuid.v1(),
      // id: '${DateFormat('yyyyMMddHHmmss').format(timeStamp)}${Authen.user.id ?? ''}',
      filePath: 'forms/sample.pdf',
      fontSize: 13,
      formLabel: 'Signature Verification',
      formLabelInfoField1: 'name',
      fields: [
        Field(
            name: 'name',
            label: 'Applicant Full Name',
            type: FieldType.string,
            posX: 210,
            posY: 265),
        Field(
            name: 'gender',
            label: 'Gender',
            type: FieldType.string,
            posX: 150,
            posY: 288),
        Field(
            name: 'dob',
            label: 'Date of birth',
            // type: FieldType.string,
            type: FieldType.date,
            keyboardType: TextInputType.datetime,
            stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            dateTimeValue: DateTime.now(),
            posX: 292,
            posY: 310),
        Field(
            name: 'email',
            label: 'Email',
            type: FieldType.string,
            posX: 140,
            posY: 333),
        Field(
            name: 'sig',
            label: 'Signature',
            type: FieldType.signature,
            sigWidth: 100,
            sigMaxHeight: 40,
            posX: 180,
            posY: 390),
        Field(
            name: 'sig_date',
            label: 'Date',
            // input: false,
            type: FieldType.date,
            keyboardType: TextInputType.datetime,
            dateTimeValue: DateTime.now(),
            stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            posX: 230,
            posY: 410),
      ],
    );
  }

  ///-------------------------------------------------------------------------
  ///LINE CHECK FORM
  ///-------------------------------------------------------------------------
  static f.Form initLineCheck() {
    DateTime timeStamp = DateTime.now();

    List<String> _gradeList = ['1', '2', '3', '4', '5', 'N/O'];
    List<String> _boolList = ['YES', 'NO'];
    List<double> _gradePosX = [307, 324, 342, 359, 377, 396];
    List<double> _competentPosX = [165, 183, 201, 219, 237, 256];
    int gradeCommentMaxLen = 180;
    return f.Form(
      type: f.FormType.lineCheck,
      formName: 'Line Check',
      createDateTime: timeStamp,
      createBy: Authen.user != null ? Authen.user.email : '',
      id: uuid.v1(),
      // id: '${DateFormat('yyyyMMddHHmmss').format(timeStamp)}${Authen.user.id ?? ''}',
      filePath: 'forms/linecheck.pdf',
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
      formLabel: 'Line Check',
      formLabelInfoField1: 'pilot_rank',
      formLabelInfoField2: 'pilot_name',
      fields: [
        ///.....................................................................
        ///PILOT
        ///.....................................................................
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
            posYList: [100, 100]),
        Field(
            name: 'pilot_name',
            label: 'Pilot Name',
            type: FieldType.string,
            section: 1,
            subSection: 1,
            // stringValue: 'Teerachart Jongkoldee',
            posX: 200,
            posY: 102),
        Field(
            name: 'pilot_license_no',
            label: 'Pilot License No.',
            type: FieldType.string,
            section: 1,
            subSection: 1,
            // stringValue: 'TH.FCL.0001234',
            posX: 152,
            posY: 127),
        Field(
            name: 'pilot_id',
            label: 'Pilot Staff ID No.(xxxx)',
            type: FieldType.string,
            section: 1,
            subSection: 1,
            maxLength: 4,
            keyboardType: TextInputType.number,
            // stringValue: '0895',
            posX: 167,
            posY: 149),

        ///.....................................................................
        ///EXAMINER
        ///.....................................................................
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
            posYList: [100, 100, 100]),
        Field(
            name: 'examiner_name',
            label: 'Examiner Name',
            type: FieldType.string,
            section: 1,
            subSection: 2,
            posX: 430,
            posY: 102),
        Field(
            name: 'examiner_license_no',
            label: 'Examiner License / Certificate No.',
            type: FieldType.string,
            section: 1,
            subSection: 2,
            posX: 360,
            posY: 127),
        Field(
            name: 'examiner_id',
            label: 'Examiner Staff ID No.(xxxx)',
            type: FieldType.string,
            section: 1,
            subSection: 2,
            maxLength: 4,
            keyboardType: TextInputType.number,
            posX: 375,
            posY: 149),

        ///.....................................................................
        ///CHECK DETAILS
        ///.....................................................................
        Field(
            name: 'type_of_check',
            label: 'Type Of Check',
            type: FieldType.radio,
            listValue: [
              'Initial',
              'Annual',
              'Recency',
              'Requalification',
              'Other'
            ],
            intValue: kInitChoice,
            section: 2,
            subSection: 1,
            page: 1,
            posXList: [45, 45, 45, 45, 45],
            posYList: [195, 212, 229, 245, 262]),
        Field(
            name: 'other_type',
            label: 'Other(if selected)',
            type: FieldType.string,
            section: 2,
            subSection: 1,
            mandatory: false,
            posX: 78,
            posY: 262),
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
            posYList: [179, 179]),
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
            posY: 246),
        Field(
            name: 'date_1',
            label: 'Sector 1 Date',
            // type: FieldType.string,
            type: FieldType.date,
            page: 1,
            section: 2,
            subSection: 2,
            keyboardType: TextInputType.datetime,
            stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            dateTimeValue: DateTime.now(),
            posX: 345,
            posY: 197),
        Field(
            name: 'flt_no_1',
            label: 'Sector 1 Flight No. (VZ___)',
            type: FieldType.string,
            page: 1,
            section: 2,
            subSection: 2,
            keyboardType: TextInputType.number,
            posX: 363,
            posY: 212),
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
            posY: 229),
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
            posY: 229),
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
            posYList: [262, 262]),
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
            posYList: [179, 179]),
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
            posY: 246),
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
            posY: 197),
        Field(
            name: 'flt_no_2',
            label: 'Sector 2 Flight No. (VZ___)',
            type: FieldType.string,
            page: 1,
            section: 2,
            subSection: 3,
            keyboardType: TextInputType.number,
            posX: 486,
            posY: 212),
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
            posY: 229),
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
            posY: 229),
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
            posYList: [262, 262]),

        ///.....................................................................
        ///GRADING
        ///.....................................................................
        Field(
            name: 'a_1',
            label:
                'Flight documents, Security check, Flight crew and Cabin crew briefing',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 1,
            posXList: _gradePosX,
            posYList: [360, 360, 360, 360, 360, 360]),
        Field(
            name: 'a_2',
            label: 'Fuel policy / FMGS preparation / X-check',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 1,
            posXList: _gradePosX,
            posYList: [373, 373, 373, 373, 373, 373]),
        Field(
            name: 'a_3',
            label: 'Aircraft status / MEL',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 1,
            posXList: _gradePosX,
            posYList: [386, 386, 386, 386, 386, 386]),
        Field(
            name: 'a_4',
            label: 'Aircraft safety inspection (Exterior and Internal)',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 1,
            posXList: _gradePosX,
            posYList: [399, 399, 399, 399, 399, 399]),
        Field(
            name: 'a_5',
            label: 'Load sheet / Takeoff performance calculation',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 1,
            posXList: _gradePosX,
            posYList: [412, 412, 412, 412, 412, 412]),
        Field(
            name: 'a_6',
            label: 'Takeoff briefing / TEM / NAVAIDS setting',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 1,
            posXList: _gradePosX,
            posYList: [425, 425, 425, 425, 425, 425]),
        Field(
            name: 'a_7',
            label: 'Timely Engine Start / Monitoring Engine Start',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 1,
            posXList: _gradePosX,
            posYList: [439, 439, 439, 439, 439, 439]),
        Field(
            name: 'a_comment',
            label: 'Comment',
            type: FieldType.string,
            page: 1,
            section: 3,
            subSection: 1,
            mandatory: false,
            maxLength: gradeCommentMaxLen,
            posX: 410,
            posY: 360,
            width: 160,
            height: 100,
            fontSize: 8),
        Field(
            name: 'b_8',
            label: 'ATC / Ground crew coordination',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 2,
            posXList: _gradePosX,
            posYList: [466, 466, 466, 466, 466, 466]),
        Field(
            name: 'b_9',
            label: 'Taxi technique',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 2,
            posXList: _gradePosX,
            posYList: [479, 479, 479, 479, 479, 479]),
        Field(
            name: 'b_10',
            label: 'Takeoff techique',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 2,
            posXList: _gradePosX,
            posYList: [492, 492, 492, 492, 492, 492]),
        Field(
            name: 'b_11',
            label: 'SID / ATC compliance',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 2,
            posXList: [307, 324, 342, 359, 377, 396],
            posYList: [505, 505, 505, 505, 505, 505]),
        Field(
            name: 'b_12',
            label: 'Noise Abatement procedures',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 2,
            posXList: _gradePosX,
            posYList: [518, 518, 518, 518, 518, 518]),
        Field(
            name: 'b_13',
            label: 'PM Support / Callouts / Procedures',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 2,
            posXList: _gradePosX,
            posYList: [531, 531, 531, 531, 531, 531]),
        Field(
            name: 'b_comment',
            label: 'Comment',
            type: FieldType.string,
            page: 1,
            section: 3,
            subSection: 2,
            mandatory: false,
            maxLength: gradeCommentMaxLen,
            posX: 410,
            posY: 466,
            width: 160,
            height: 100,
            fontSize: 8),
        Field(
            name: 'c_14',
            label: 'Climb technique / Procedure',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 3,
            posXList: _gradePosX,
            posYList: [559, 559, 559, 559, 559, 559]),
        Field(
            name: 'c_15',
            label: 'Altitude selection / Step climb',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 3,
            posXList: _gradePosX,
            posYList: [572, 572, 572, 572, 572, 572]),
        Field(
            name: 'c_16',
            label: 'In-flight planning / Re-planning / Emergency procedures',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 3,
            posXList: _gradePosX,
            posYList: [585, 585, 585, 585, 585, 585]),
        Field(
            name: 'c_17',
            label: 'Enroute Comms / ATC procedure and compliance',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 3,
            posXList: _gradePosX,
            posYList: [598, 598, 598, 598, 598, 598]),
        Field(
            name: 'c_18',
            label: 'CAT / Wake Turbulence / WX Avoidance procedures',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 3,
            posXList: _gradePosX,
            posYList: [611, 611, 611, 611, 611, 611]),
        Field(
            name: 'c_comment',
            label: 'Comment',
            type: FieldType.string,
            page: 1,
            section: 3,
            subSection: 3,
            mandatory: false,
            maxLength: gradeCommentMaxLen,
            posX: 410,
            posY: 559,
            width: 160,
            height: 100,
            fontSize: 8),
        Field(
            name: 'd_19',
            label: 'Descent planning / Briefing / TEM / Situation awareness',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [639, 639, 639, 639, 639, 639]),
        Field(
            name: 'd_20',
            label:
                'Profile management / Speed / Altitude / Aircraft configuration',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [652, 652, 652, 652, 652, 652]),
        Field(
            name: 'd_21',
            label: 'STAR / ATC compliance',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [665, 665, 665, 665, 665, 665]),
        Field(
            name: 'd_22',
            label: 'Approach procedures',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [678, 678, 678, 678, 678, 678]),
        Field(
            name: 'd_23',
            label: 'Stabilized Approach Criteria',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [691, 691, 691, 691, 691, 691]),
        Field(
            name: 'd_24',
            label: 'Landing technique',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [704, 704, 704, 704, 704, 704]),
        Field(
            name: 'd_25',
            label:
                'Reversers / Braking / Runway clearance (Vacating) / Runway occupancy time',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [725, 725, 725, 725, 725, 725]),
        Field(
            name: 'd_26',
            label: 'Parking / Shut Down procedure',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [738, 738, 738, 738, 738, 738]),
        Field(
            name: 'd_27',
            label: 'Post-Flight documents / Procedures',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [751, 751, 751, 751, 751, 751]),
        Field(
            name: 'd_28',
            label: 'PM support',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 1,
            section: 3,
            subSection: 4,
            posXList: _gradePosX,
            posYList: [764, 764, 764, 764, 764, 764]),
        Field(
            name: 'd_comment',
            label: 'Comment',
            type: FieldType.string,
            page: 1,
            section: 3,
            subSection: 4,
            mandatory: false,
            maxLength: gradeCommentMaxLen,
            posX: 410,
            posY: 639,
            width: 160,
            height: 100,
            fontSize: 8),
        Field(
            name: 'e_29',
            label: 'Crew Resource Management (CRM)',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 3,
            subSection: 5,
            posXList: _gradePosX,
            posYList: [114, 114, 114, 114, 114, 114]),
        Field(
            name: 'e_30',
            label: 'Threat & Error Management (TEM)',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 3,
            subSection: 5,
            posXList: _gradePosX,
            posYList: [127, 127, 127, 127, 127, 127]),
        Field(
            name: 'e_31',
            label: 'Assertiveness',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 3,
            subSection: 5,
            posXList: _gradePosX,
            posYList: [140, 140, 140, 140, 140, 140]),
        Field(
            name: 'e_32',
            label: 'Interpersonal Skills',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 3,
            subSection: 5,
            posXList: _gradePosX,
            posYList: [153, 153, 153, 153, 153, 153]),
        Field(
            name: 'e_33',
            label: 'Security-Safety Attitude',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 3,
            subSection: 5,
            posXList: _gradePosX,
            posYList: [166, 166, 166, 166, 166, 166]),
        Field(
            name: 'e_34',
            label: 'Public Address (PA)',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 3,
            subSection: 5,
            posXList: _gradePosX,
            posYList: [179, 179, 179, 179, 179, 179]),
        Field(
            name: 'e_comment',
            label: 'Comment',
            type: FieldType.string,
            page: 2,
            section: 3,
            subSection: 5,
            mandatory: false,
            maxLength: gradeCommentMaxLen,
            posX: 410,
            posY: 114,
            width: 160,
            height: 100,
            fontSize: 8),

        ///.....................................................................
        ///BRIEFING ITEM
        ///.....................................................................
        Field(
            name: 'brief_1',
            label: 'Hard Landing Awareness',
            type: FieldType.radio,
            listValue: _boolList,
            intValue: kInitChoice,
            page: 2,
            section: 4,
            subSection: 1,
            posXList: [307, 324],
            posYList: [262, 262]),
        Field(
            name: 'brief_2',
            label: 'Stabilized Approach Technique',
            type: FieldType.radio,
            listValue: _boolList,
            intValue: kInitChoice,
            page: 2,
            section: 4,
            subSection: 1,
            posXList: [307, 324],
            posYList: [275, 275]),
        Field(
            name: 'brief_3',
            label: 'Intercept From Above',
            type: FieldType.radio,
            listValue: _boolList,
            intValue: kInitChoice,
            page: 2,
            section: 4,
            subSection: 1,
            posXList: [307, 324],
            posYList: [288, 288]),
        Field(
            name: 'brief_4',
            label: 'Green Operations and Fuel Policy',
            type: FieldType.radio,
            listValue: _boolList,
            intValue: kInitChoice,
            page: 2,
            section: 4,
            subSection: 1,
            posXList: [307, 324],
            posYList: [301, 301]),
        Field(
            name: 'brief_5',
            label: 'Other',
            type: FieldType.radio,
            listValue: _boolList,
            intValue: kInitChoice,
            page: 2,
            section: 4,
            subSection: 1,
            posXList: [307, 324],
            posYList: [314, 314]),
        Field(
            name: 'brief_comment',
            label: 'Comment',
            type: FieldType.string,
            page: 2,
            section: 4,
            subSection: 1,
            mandatory: false,
            maxLength: 300,
            posX: 342,
            posY: 264,
            width: 220,
            height: 100,
            fontSize: 8),

        ///.....................................................................
        ///COMPETENCY ASSESSMENT AND COMMENTS
        ///.....................................................................
        Field(
            name: 'comp_pro',
            label: 'PRO',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [399, 399, 399, 399, 399, 399]),
        Field(
            name: 'comp_com',
            label: 'COM',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [412, 412, 412, 412, 412, 412]),
        Field(
            name: 'comp_fpa',
            label: 'FPA',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [425, 425, 425, 425, 425, 425]),
        Field(
            name: 'comp_fpm',
            label: 'FPM',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [440, 440, 440, 440, 440, 440]),
        Field(
            name: 'comp_kno',
            label: 'KNO',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [453, 453, 453, 453, 453, 453]),
        Field(
            name: 'comp_ltw',
            label: 'LTW',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [466, 466, 466, 466, 466, 466]),
        Field(
            name: 'comp_psd',
            label: 'PSD',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [481, 481, 481, 481, 481, 481]),
        Field(
            name: 'comp_saw',
            label: 'SAW',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [494, 494, 494, 494, 494, 494]),
        Field(
            name: 'comp_wlm',
            label: 'WLM',
            type: FieldType.radio,
            listValue: _gradeList,
            intValue: kInitChoice,
            page: 2,
            section: 5,
            subSection: 1,
            posXList: _competentPosX,
            posYList: [507, 507, 507, 507, 507, 507]),
        Field(
            name: 'general_comment',
            label: 'General Comment',
            type: FieldType.string,
            page: 2,
            section: 5,
            subSection: 1,
            mandatory: false,
            maxLength: 500,
            posX: 280,
            posY: 401,
            width: 280,
            height: 100,
            fontSize: 8),

        ///.....................................................................
        ///OVERALL GRADING
        ///.....................................................................
        Field(
            name: 'result',
            label: 'Result',
            type: FieldType.radio,
            listValue: ['Not Competent', 'Competent'],
            intValue: kInitChoice,
            page: 2,
            section: 6,
            subSection: 1,
            posXList: [145, 145],
            posYList: [549, 590]),
        Field(
            name: 'competent_level',
            label: 'Competent Level',
            type: FieldType.radio,
            listValue: [
              'Improvement Required',
              'Average',
              'Above Average',
              'Good'
            ],
            intValue: kInitChoice,
            page: 2,
            section: 6,
            subSection: 1,
            posXList: [215, 215, 215, 215],
            posYList: [565, 582, 599, 616]),
        Field(
            name: 'result_comment',
            label: 'Comment',
            type: FieldType.string,
            page: 2,
            section: 6,
            subSection: 1,
            mandatory: false,
            maxLength: 300,
            posX: 324,
            posY: 552,
            width: 230,
            height: 100,
            fontSize: 8),
        Field(
            name: 'pilot_sig',
            label: 'Pilot\'s Signature',
            type: FieldType.signature,
            sigWidth: 100,
            sigMaxHeight: 60,
            page: 2,
            section: 7,
            posX: 80,
            posY: 720),
        Field(
            // name: 'PILOT_NAME',
            // label: 'Pilot Name',
            duplicateFrom: 'pilot_name',
            mandatory: false,
            input: false,
            type: FieldType.string,
            page: 2,
            section: 7,
            posX: 70,
            posY: 741),
        Field(
            name: 'pilot_sig_date',
            label: 'Date',
            // input: false,
            // mandatory: true,
            type: FieldType.date,
            keyboardType: TextInputType.datetime,
            page: 2,
            section: 7,
            stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            dateTimeValue: DateTime.now(),
            posX: 70,
            posY: 757),

        ///++++++++++++++++++++++++++++++++++++++++++++++++
        Field(
            name: 'examiner_sig',
            label: 'Examiner\'s Signature',
            type: FieldType.signature,
            sigWidth: 100,
            sigMaxHeight: 60,
            page: 2,
            section: 7,
            posX: 250,
            posY: 720),
        Field(
            // name: 'PILOT_NAME',
            // label: 'Pilot Name',
            duplicateFrom: 'examiner_name',
            input: false,
            mandatory: false,
            type: FieldType.string,
            page: 2,
            section: 7,
            posX: 250,
            posY: 741),
        Field(
            name: 'examiner_sig_date',
            label: 'Date',
            // input: false,
            type: FieldType.date,
            keyboardType: TextInputType.datetime,
            dateTimeValue: DateTime.now(),
            // mandatory: false,
            page: 2,
            section: 7,
            stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
            posX: 250,
            posY: 757),
      ],
    );
  }

  // static f.Form initLOE() {
  //   DateTime timeStamp = DateTime.now();
  //
  //   // ///-------------------------------------------------------------------------
  //   // ///LOE FORM
  //   // ///-------------------------------------------------------------------------
  //   return f.Form(
  //     type: f.FormType.loe,
  //     formName: 'Letter Of Explanation (LOE)',
  //     createDateTime: timeStamp,
  //     createBy: Authen.user != null ? Authen.user.email : '',
  //     id: uuid.v1(),
  //     filePath: 'forms/loe.pdf',
  //     fontSize: 13,
  //     formLabel: 'LOE',
  //     formLabelInfoField1: 'subject',
  //     fields: [
  //       Field(
  //           name: 'DATE',
  //           label: 'Date',
  //           type: FieldType.date,
  //           keyboardType: TextInputType.datetime,
  //           stringValue: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  //           posX: 110,
  //           posY: 140),
  //       Field(
  //           name: 'id',
  //           label: 'Staff ID',
  //           type: FieldType.string,
  //           maxLength: 7,
  //           stringValue: 'TVJ',
  //           posX: 390,
  //           posY: 104),
  //       Field(
  //           name: 'name',
  //           label: 'Staff Name',
  //           type: FieldType.string,
  //           posX: 130,
  //           posY: 104),
  //       Field(
  //           name: 'position',
  //           label: 'Position',
  //           type: FieldType.string,
  //           posX: 390,
  //           posY: 140),
  //       Field(
  //           name: 'subject',
  //           label: 'Subject',
  //           type: FieldType.string,
  //           stringValue: 'Subject of loe',
  //           posX: 115,
  //           posY: 122),
  //       Field(
  //           name: 'narrative',
  //           label: 'Narrative(describe the details)',
  //           type: FieldType.string,
  //           mandatory: false,
  //           maxLength: 800,
  //           maxLine: 10,
  //           posX: 70,
  //           posY: 196,
  //           width: 480,
  //           height: 500),
  //       Field(
  //           name: 'sig',
  //           label: 'Signature1',
  //           type: FieldType.signature,
  //           sigWidth: 150,
  //           sigMaxHeight: 60,
  //           posX: 105,
  //           posY: 630),
  //     ],
  //   );
  // }
}
