import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import 'package:marverick/utils/constants.dart';

enum FieldType {
  string,
  date,
  bool,
  int,
  image,
  signature,
  dropdown,
  radio,
  checkbox,
}

class Field extends ChangeNotifier {
  ///Field's name
  final String name;

  ///Field's label
  String label;

  ///Copy value from other field but display on different position in PDF.
  String? duplicateFrom;

  Uint8List? signature;
  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: kPenColor,
    exportBackgroundColor: Colors.transparent,
    onDrawEnd: () {},
  );

  Future convertSignature(void Function(String) callback, bool allowDelete) async {
    final Uint8List? data = await controller.toPngBytes();
    // signature = data;
    // callback(kStatusSuccess);
    if (data != null || allowDelete) {
      signature = data;
      callback(kStatusSuccess);
    }
    // else {
    //   callback(kStatusError);
    // }
  }

  ///True type of field's value
  FieldType type;
  int minLength;
  int? maxLength;
  int? maxLine;

  /// Main section in form
  int section;

  /// Sub-section in form
  int subSection;

  /// Sub-section in grading area (A, B, C, D ...)
  int gradeSection;
  bool isMandatory;

  /// Show field in input screen
  bool input;

  /// Display in PDF page...
  double page;
  double posX;
  double posY;
  List<double> posXList;
  List<double> posYList;
  double? width;
  double? height;
  double sigWidth;
  double sigMaxHeight;
  double? fontSize;
  TextInputType? keyboardType;
  TextCapitalization textCapitalization;

  /// Write this field in PDF
  bool writePdf;

  ///data
  String stringValue;
  int intValue;
  bool boolValue;
  DateTime? dateTimeValue;
  List<String> listValue;
  List<bool> checkBoxValue;

  Field({
    this.name = '',
    this.label = '',
    this.duplicateFrom,
    required this.type,
    this.minLength = 0,
    this.maxLength,
    this.maxLine,
    this.isMandatory = true,
    this.input = true,
    this.stringValue = '',
    this.dateTimeValue,
    this.listValue = const [],
    this.checkBoxValue = const [],
    this.posXList = const [],
    this.posYList = const [],
    this.intValue = -1,
    this.boolValue = false,
    this.page = 1,
    this.section = 1,
    this.subSection = 1,
    this.gradeSection = 0,
    this.posX = 0,
    this.posY = 0,
    this.width,
    this.height,
    this.sigWidth = 0,
    this.sigMaxHeight = 0,
    this.fontSize,
    this.textCapitalization = TextCapitalization.characters,
    this.keyboardType,
    this.writePdf = true,
  });
}
