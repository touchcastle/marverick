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
}

class Field extends ChangeNotifier {
  ///Field's name
  final String name;

  ///Field's label
  String label;

  ///Copy value from other field but display on different place.
  String? duplicateFrom;

  Uint8List? signature;
  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: kPenColor,
    exportBackgroundColor: Colors.transparent,
    onDrawEnd: () {},
  );

  Future convertSignature(void Function(String) callback) async {
    final Uint8List? data = await controller.toPngBytes();
    if (data != null) {
      signature = data;
      callback(kStatusSuccess);
    } else {
      callback(kStatusError);
    }
  }

  ///True type of field's value
  FieldType type;
  int minLength;
  int? maxLength;
  int? maxLine;
  int section;
  int subSection;
  bool mandatory;
  bool input;
  double page;
  double posX;
  double posY;
  double? width;
  double? height;
  List<double> posXList;
  List<double> posYList;
  double sigWidth;
  double sigMaxHeight;
  double? fontSize;
  TextInputType? keyboardType;
  TextCapitalization textCapitalization;

  ///data
  String stringValue;
  int intValue;
  bool boolValue;
  DateTime? dateTimeValue;
  List<String> listValue;

  Field({
    this.name = '',
    this.label = '',
    this.duplicateFrom,
    required this.type,
    this.minLength = 0,
    this.maxLength,
    this.maxLine,
    this.mandatory = true,
    this.input = true,
    this.stringValue = '',
    this.dateTimeValue,
    this.listValue = const [],
    this.posXList = const [],
    this.posYList = const [],
    this.intValue = 0,
    this.boolValue = false,
    this.page = 1,
    this.section = 1,
    this.subSection = 1,
    this.posX = 20,
    this.posY = 20,
    this.width,
    this.height,
    this.sigWidth = 0,
    this.sigMaxHeight = 0,
    this.fontSize,
    this.textCapitalization = TextCapitalization.characters,
    this.keyboardType,
  });
}
