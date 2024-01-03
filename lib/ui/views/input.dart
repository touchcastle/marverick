import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/models/field.dart';
import 'package:marverick/services/pdf.dart';
import 'package:marverick/services/form_service.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/ui/views/main_menu.dart';
import 'package:marverick/ui/views/log_in.dart';
import 'package:marverick/ui/widgets/snackbar.dart';
import 'package:marverick/ui/widgets/SignaturePad.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/utils/utils.dart';

class InputScreen extends StatefulWidget {
  static const id = kInputId; //for route.
  final f.Form form;

  InputScreen({required this.form});

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  bool toggleMandatory = false;

  // late SignaturePad signaturePad;
  // late Widget currentPage;

  @override
  void initState() {
    super.initState();
    Utils.context = context;
  }

  void callback() => setState(() {});

  @override
  void dispose() {
    super.dispose();
  }

  //Method to Submit Feedback and save it in Google Sheets
  Future _submitForm(BuildContext c) async {
    int indexPage = 0;
    String message = '';

    print(Authen.user);
    if (Authen.user == null) {
      await Navigator.of(context).push(PageRouteBuilder(
          settings: const RouteSettings(name: kMainPageName),
          pageBuilder: (_, __, ___) => Login(fromInside: true)));
    }
    if (Authen.user != null) {
      ErrorType errorType = ErrorType.success;
      await context.read<FormService>().submitForm(widget.form,
          (String response, ErrorType type) {
        errorType = type;
        if (response == kStatusSuccess) {
          message = 'SUCCESS: form submitted';
        } else {
          message = response;
          indexPage = 1;
        }
      });
      Snackbar.show(context,
          text: message,
          type: errorType == ErrorType.noInternet
              ? Type.caution
              : errorType == ErrorType.success
                  ? Type.info
                  : Type.error,
          isFixed: errorType == ErrorType.noInternet
              ? true
              : errorType == ErrorType.success
                  ? true
                  : false);
      if (errorType != ErrorType.missingRequired) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
            settings: const RouteSettings(name: kMainPageName),
            pageBuilder: (_, __, ___) => MainMenu(selectedIndex: indexPage)));
      } else if (errorType == ErrorType.missingRequired) {
        setState(() {
          toggleMandatory = true;
        });
      }
    }
  }

  Future _autoSave({bool showLoad = false}) async {
    await context.read<FormService>().save(widget.form, showLoad: showLoad);
  }

  TextStyle label() =>
      TextStyle(color: Colors.black54, fontWeight: FontWeight.w500);

  TextStyle subLabel() => TextStyle(
      fontSize: 12,
      color: Colors.black54,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic);

  TextStyle value() =>
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold);

  TextStyle header() => TextStyle(
      color: kPrimaryDarker, fontWeight: FontWeight.bold, fontSize: 18);

  TextStyle subHeader() => TextStyle(
      color: kSecondaryDarker, fontWeight: FontWeight.bold, fontSize: 16);

  Widget boxContainer(
      {required FieldType fieldType, required List<Widget> children}) {
    if (fieldType == FieldType.radio || fieldType == FieldType.signature) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
    } else {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
      // return Row(children: children);
    }
  }

  Widget valueContainer({required FieldType fieldType, required Widget child}) {
    if (fieldType == FieldType.radio || fieldType == FieldType.signature) {
      return Container(child: child);
    } else {
      return Container(child: child);
      // return Expanded(child: child);
    }
  }

  Widget spacer({required FieldType fieldType}) {
    if (fieldType == FieldType.radio || fieldType == FieldType.signature) {
      return SizedBox(height: 10);
    } else {
      return SizedBox(height: 10);
      // return SizedBox(width: 10);
    }
  }

  bool isMandatoryEmpty(int index) =>
      widget.form.fields[index].mandatory &&
          ((widget.form.fields[index].type == FieldType.string ||
                  widget.form.fields[index].type == FieldType.radio) &&
              widget.form.fields[index].stringValue == '' &&
              widget.form.fields[index].intValue < 0) ||
      (widget.form.fields[index].type == FieldType.signature &&
          widget.form.fields[index].controller.isEmpty) ||
      (widget.form.fields[index].type == FieldType.int &&
          widget.form.fields[index].intValue >= 0);

  Future<bool> _onWillPop() async {
    _autoSave();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    bool writeHeader = false;
    bool writeGradeSecHeader = false;
    bool writeSpace = false;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(color: Colors.white),
            elevation: 0,
            backgroundColor: kPrimary,
            title: Text(
              widget.form.formName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  // _submitForm();
                  setState(() {});
                  await _autoSave(showLoad: true);
                  await context.read<Pdf>().lunchPdf(widget.form);
                },
              ),
              TextButton(
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  setState(() {});
                  await _submitForm(context);
                  // await context.read<Pdf>().gen(widget.form);
                },
              )
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              formProgress(),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox.expand(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: widget.form.sectionLabel.length,
                              itemBuilder: (BuildContext context, int section) {
                                String sectionName =
                                    widget.form.sectionLabel[section];
                                List<Field> fieldList =
                                    List.from(widget.form.fields);
                                return ExpansionTile(
                                    shape: const Border(),
                                    title: Align(
                                      alignment: Alignment.centerLeft,
                                      child: sectionLabel(sectionName),
                                    ),
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true, // new
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: widget.form.fields.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Field field =
                                                widget.form.fields[index];
                                            Field previousField;
                                            if (index == 0) {
                                              previousField =
                                                  widget.form.fields[index];
                                            } else {
                                              previousField =
                                                  widget.form.fields[index - 1];
                                            }

                                            if (field.input &&
                                                field.section == section + 1) {
                                              writeHeader = false;
                                              if (index > 0 &&
                                                  field.subSection >
                                                      previousField
                                                          .subSection) {
                                                writeSpace = true;
                                              } else {
                                                writeSpace = false;
                                              }
                                              if (index > 0 &&
                                                  field.gradeSection >
                                                      previousField
                                                          .gradeSection) {
                                                writeGradeSecHeader = true;
                                              } else {
                                                writeGradeSecHeader = false;
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 13),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // writeHeader &&
                                                    //         widget.form
                                                    //                 .sectionLabel !=
                                                    //             null
                                                    //     ? sectionLabel(field)
                                                    //     : SizedBox.shrink(),
                                                    writeSpace
                                                        ? subSectionDivide()
                                                        : SizedBox.shrink(),
                                                    writeGradeSecHeader &&
                                                            widget.form
                                                                    .gradeSectionLabel !=
                                                                null
                                                        ? gradeSectionLabel(
                                                            field)
                                                        : SizedBox.shrink(),
                                                    formField(
                                                        index, field, context),
                                                    SizedBox(height: 8),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          }),
                                    ]);
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container formProgress() {
    return Container(
      height: 35,
      color: kSecondary,
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${widget.form.filledRequired()} / ${widget.form.allRequired()}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          widget.form.filledRequired() < widget.form.allRequired()
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(toggleMandatory
                        ? Icons.pageview
                        : Icons.pageview_outlined),
                    iconSize: 30,
                    onPressed: () {
                      setState(() {
                        toggleMandatory = !toggleMandatory;
                      });
                    },
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Container formField(int index, Field field, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: !toggleMandatory
            ? Colors.transparent
            : isMandatoryEmpty(index)
                ? Colors.redAccent
                : Colors.transparent,
        border: Border.all(
            color: !toggleMandatory
                ? Colors.black26
                : isMandatoryEmpty(index)
                    ? Colors.red
                    : Colors.black26),
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: boxContainer(
        fieldType: field.type,
        children: [
          Row(
            children: [
              Text(
                field.label,
                style: label(),
                overflow: TextOverflow.fade,
              ),
              field.type == FieldType.checkbox
                  ? Text(
                      '   (you can select more than 1 answer)',
                      style: subLabel(),
                      overflow: TextOverflow.fade,
                    )
                  : SizedBox.shrink()
            ],
          ),
          spacer(fieldType: field.type),
          valueContainer(
            fieldType: field.type,
            child: field.type == FieldType.signature
                // ? signaturePad(index)
                ? SignaturePad(
                    callback: this.callback,
                    field: field,
                    onSave: _autoSave,
                  )
                : field.type == FieldType.radio
                    ? radioButtonChoices(index)
                    : field.type == FieldType.checkbox
                        ? checkBoxChoices(index)
                        : field.type == FieldType.date
                            ? dateInput(index, context)
                            : field.maxLength != null && field.maxLength! > 100
                                ? textForm(index)
                                : textField(index),
          ),
          // SizedBox(height: 10),
        ],
      ),
    );
  }

  Column subSectionDivide() {
    return Column(
      children: [
        SizedBox(height: 2),
        Center(child: Text('---------', style: label())),
        SizedBox(height: 10),
      ],
    );
  }

  Column sectionLabel(String section) {
    return Column(
      children: [
        // field.section > 1
        //     ? Column(
        //         children: [SizedBox(height: 30)],
        //       )
        //     : SizedBox.shrink(),
        Text(
          section,
          style: header(),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Column gradeSectionLabel(Field field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        field.gradeSection > 1
            ? Column(
                children: [SizedBox(height: 20)],
              )
            : SizedBox.shrink(),
        Text(
          '  ${widget.form.gradeSectionLabel![field.gradeSection - 1]}',
          style: subHeader(),
        ),
        SizedBox(height: 6),
      ],
    );
  }

  ///To input date as date picker
  Widget dateInput(int index, BuildContext c) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        // child: Text(widget.form.fields[index].stringValue),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 1.3),
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.transparent,
          ),
          child: Text(widget.form.fields[index].stringValue, style: value()),
        ),
        onPressed: () async {
          showDialog(
            context: c,
            builder: (_) => datePicker(index),
          );
        },
      ),
    );
  }

  AlertDialog datePicker(int index) {
    return AlertDialog(
      // title: Text(widget.form.fields[index].label, style: label()),
      backgroundColor: Colors.white,
      elevation: 0,
      content: Container(
        width: 400,
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Center(
          child: SfDateRangePicker(
            selectionTextStyle: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),

            selectionRadius: 0,
            // selectionShape: DateRangePickerSelectionShape.rectangle,
            // selectionColor: Colors.transparent,
            onSelectionChanged: (args) {
              setState(() {
                widget.form.fields[index].dateTimeValue = args.value;
                widget.form.fields[index].stringValue =
                    DateFormat(widget.form.dateFormat).format(args.value).toUpperCase();

                // if (widget.form.type == f.FormType.lineCheck) {
                //   widget.form.fields[index].stringValue =
                //       DateFormat('dd/MM/yyyy').format(args.value);
                // } else {
                //   widget.form.fields[index].stringValue =
                //       DateFormat('dd MMM yyyy').format(args.value).toUpperCase();
                // }
              });
            },
            initialSelectedDate: widget.form.fields[index].dateTimeValue,
            // initialSelectedRange: PickerDateRange(
            //     DateTime.now().subtract(const Duration(days: 4)),
            //     DateTime.now().add(const Duration(days: 3))),
          ),
        ),
      ),
    );
  }

  TextFormField textForm(int index) {
    return TextFormField(
      enabled: widget.form.fields[index].input,
      controller: TextEditingController()
        ..text = widget.form.fields[index].stringValue,
      maxLines: widget.form.fields[index].maxLine ?? 5,
      maxLength: widget.form.fields[index].maxLength,
      onChanged: (text) => widget.form.fields[index].stringValue = text,
      onEditingComplete: () => _autoSave(),
      onSaved: (value) => _autoSave(),
      decoration: textInputDecor(),
      style: value(),
    );
  }

  Widget textField(int index) {
    return TextField(
      key: Key('${widget.form.id}${widget.form.fields[index].name}'),
      keyboardType: widget.form.fields[index].keyboardType,
      textCapitalization: widget.form.fields[index].textCapitalization,
      enabled: widget.form.fields[index].input,
      controller: TextEditingController()
        ..text = widget.form.fields[index].stringValue,
      maxLength: widget.form.fields[index].maxLength,
      onChanged: (text) => widget.form.fields[index].stringValue = text,
      onSubmitted: (text) {
        _autoSave();
        setState(() {});
      },
      decoration: textInputDecor(),
      textAlign: TextAlign.end,
      style: value(),
    );
  }

  Widget radioButtonChoices(int index) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int radio = 0;
              radio < widget.form.fields[index].listValue.length;
              radio++)
            Row(
              children: [
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: widget.form.fields[index].intValue == radio
                              ? kSecondaryDarker
                              : Colors.black12,
                          width: 1.3),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: widget.form.fields[index].intValue == radio
                          ? kSecondary
                          : Colors.transparent,
                    ),
                    child: Text(widget.form.fields[index].listValue[radio],
                        style: value()),
                  ),
                  onTap: () {
                    setState(() {
                      ///Click new radio button
                      if (widget.form.fields[index].intValue != radio) {
                        widget.form.fields[index].intValue = radio;
                        widget.form.fields[index].stringValue =
                            widget.form.fields[index].listValue[radio];
                      }

                      ///Click same radio button
                      else {
                        widget.form.fields[index].intValue = -1;
                        widget.form.fields[index].stringValue = '';
                      }
                      _autoSave();
                    });
                  },
                ),
                SizedBox(width: 5),
              ],
            ),
        ],
      ),
    );
  }

  Widget checkBoxChoices(int index) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int checkIndex = 0;
              checkIndex < widget.form.fields[index].checkBoxValue.length;
              checkIndex++)
            Row(
              children: [
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: widget
                                  .form.fields[index].checkBoxValue[checkIndex]
                              ? kSecondaryDarker
                              : Colors.black12,
                          width: 1.3),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: widget.form.fields[index].checkBoxValue[checkIndex]
                          ? kSecondary
                          : Colors.transparent,
                    ),
                    child: Text(widget.form.fields[index].listValue[checkIndex],
                        style: value()),
                  ),
                  onTap: () {
                    setState(() {
                      widget.form.fields[index].checkBoxValue[checkIndex] =
                          !widget.form.fields[index].checkBoxValue[checkIndex];
                      String _name = widget.form.fields[index].name +
                          '_' +
                          checkIndex.toString();
                      print(_name);
                      widget
                              .form
                              .fields[widget.form.fields
                                  .indexWhere((e) => e.name == _name)]
                              .stringValue =
                          widget.form.fields[index].checkBoxValue[checkIndex]
                              .toString();
                      print(widget
                          .form
                          .fields[widget.form.fields
                              .indexWhere((e) => e.name == _name)]
                          .stringValue);

                      // if (widget.form.fields[index].intValue != checkIndex) {
                      //   widget.form.fields[index].intValue = checkIndex;
                      //   widget.form.fields[index].stringValue =
                      //       widget.form.fields[index].listValue[checkIndex];
                      // } else {
                      //   widget.form.fields[index].intValue = -1;
                      //   widget.form.fields[index].stringValue = '';
                      // }
                      _autoSave();
                    });
                  },
                ),
                SizedBox(width: 5),
              ],
            ),
        ],
      ),
    );
  }

// Widget signaturePad(int index) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Text(widget.form.fields[_index].label),
//       //SIGNATURE CANVAS
//       widget.form.fields[index].signature != null
//           ? Image.memory(
//               Uint8List.fromList(widget.form.fields[index].signature!))
//           : SizedBox.shrink(),
//       ClipRRect(
//         child: SizedBox(
//           // height: 180,
//           child: Signature(
//             controller: widget.form.fields[index].controller,
//             height: 180,
//             // width: 390,
//             backgroundColor: Color(0xffeeeeee),
//           ),
//         ),
//       ),
//       //OK AND CLEAR BUTTONS
//       Container(
//         decoration: const BoxDecoration(color: kPrimaryDarker),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             //SHOW EXPORTED IMAGE IN NEW ROUTE
//             IconButton(
//               icon: const Icon(Icons.save),
//               color: kSecondary,
//               onPressed: () async {
//                 await widget.form.fields[index]
//                     .convertSignature((String response) async {
//                   if (response == kStatusSuccess) {
//                     await _autoSave();
//                   } else {
//                     Snackbar.show(context,
//                         text: 'Please sign your signature',
//                         type: Type.error,
//                         isFixed: false);
//                   }
//                 });
//                 setState(() {});
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.undo),
//               color: kSecondary,
//               onPressed: () async {
//                 setState(() => widget.form.fields[index].controller.undo());
//                 // widget.form.fields[index].sigStore();
//                 // await _autoSave();
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.redo),
//               color: kSecondary,
//               onPressed: () async {
//                 setState(() => widget.form.fields[index].controller.redo());
//                 // widget.form.fields[index].sigStore();
//                 // await _autoSave();
//               },
//             ),
//             //CLEAR CANVAS
//             IconButton(
//               icon: const Icon(Icons.delete),
//               color: kSecondary,
//               onPressed: () {
//                 setState(() {
//                   widget.form.fields[index].controller.clear();
//                   // widget.form.fields[index].signature = null;
//                 });
//                 _autoSave();
//               },
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }
}

// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'dart:typed_data';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:signature/signature.dart';
// import 'package:intl/intl.dart';
// import 'package:marverick/models/form.dart' as f;
// import 'package:marverick/models/field.dart';
// import 'package:marverick/services/pdf.dart';
// import 'package:marverick/services/form_service.dart';
// import 'package:marverick/services/authen.dart';
// import 'package:marverick/ui/views/main_menu.dart';
// import 'package:marverick/ui/views/log_in.dart';
// import 'package:marverick/ui/widgets/snackbar.dart';
// import 'package:marverick/ui/widgets/SignaturePad.dart';
// import 'package:marverick/utils/constants.dart';
// import 'package:marverick/utils/utils.dart';
//
// class InputScreen extends StatefulWidget {
//   static const id = kInputId; //for route.
//   final f.Form form;
//
//   InputScreen({required this.form});
//
//   @override
//   _InputScreenState createState() => _InputScreenState();
// }
//
// class _InputScreenState extends State<InputScreen> {
//   bool toggleMandatory = false;
//
//   @override
//   void initState() {
//     super.initState();
//     Utils.context = context;
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   //Method to Submit Feedback and save it in Google Sheets
//   Future _submitForm(BuildContext c) async {
//     int indexPage = 0;
//     String message = '';
//
//     print(Authen.user);
//     if (Authen.user == null) {
//       await Navigator.of(context).push(PageRouteBuilder(
//           settings: const RouteSettings(name: kMainPageName),
//           pageBuilder: (_, __, ___) => Login(fromInside: true)));
//     }
//     if (Authen.user != null) {
//       ErrorType errorType = ErrorType.success;
//       await context.read<FormService>().submitForm(widget.form,
//           (String response, ErrorType type) {
//         errorType = type;
//         if (response == kStatusSuccess) {
//           message = 'SUCCESS: form submitted';
//         } else {
//           message = response;
//           indexPage = 1;
//         }
//       });
//       Snackbar.show(context,
//           text: message,
//           type: errorType == ErrorType.noInternet
//               ? Type.caution
//               : errorType == ErrorType.success
//                   ? Type.info
//                   : Type.error,
//           isFixed: errorType == ErrorType.noInternet
//               ? true
//               : errorType == ErrorType.success
//                   ? true
//                   : false);
//       if (errorType != ErrorType.missingRequired) {
//         Navigator.of(context).pushReplacement(PageRouteBuilder(
//             settings: const RouteSettings(name: kMainPageName),
//             pageBuilder: (_, __, ___) => MainMenu(selectedIndex: indexPage)));
//       } else if (errorType == ErrorType.missingRequired) {
//         setState(() {
//           toggleMandatory = true;
//         });
//       }
//     }
//   }
//
//   Future _autoSave({bool showLoad = false}) async {
//     await context.read<FormService>().save(widget.form, showLoad: showLoad);
//   }
//
//   TextStyle label() =>
//       TextStyle(color: Colors.black54, fontWeight: FontWeight.w500);
//
//   TextStyle subLabel() => TextStyle(
//       fontSize: 12,
//       color: Colors.black54,
//       fontWeight: FontWeight.w400,
//       fontStyle: FontStyle.italic);
//
//   TextStyle value() =>
//       TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
//
//   TextStyle header() => TextStyle(
//       color: kPrimaryDarker, fontWeight: FontWeight.bold, fontSize: 18);
//
//   TextStyle subHeader() => TextStyle(
//       color: kSecondaryDarker, fontWeight: FontWeight.bold, fontSize: 16);
//
//   Widget boxContainer(
//       {required FieldType fieldType, required List<Widget> children}) {
//     if (fieldType == FieldType.radio || fieldType == FieldType.signature) {
//       return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
//     } else {
//       return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
//       // return Row(children: children);
//     }
//   }
//
//   Widget valueContainer({required FieldType fieldType, required Widget child}) {
//     if (fieldType == FieldType.radio || fieldType == FieldType.signature) {
//       return Container(child: child);
//     } else {
//       return Container(child: child);
//       // return Expanded(child: child);
//     }
//   }
//
//   Widget spacer({required FieldType fieldType}) {
//     if (fieldType == FieldType.radio || fieldType == FieldType.signature) {
//       return SizedBox(height: 10);
//     } else {
//       return SizedBox(height: 10);
//       // return SizedBox(width: 10);
//     }
//   }
//
//   bool isMandatoryEmpty(int index) =>
//       widget.form.fields[index].mandatory &&
//           ((widget.form.fields[index].type == FieldType.string ||
//                   widget.form.fields[index].type == FieldType.radio) &&
//               widget.form.fields[index].stringValue == '') ||
//       (widget.form.fields[index].type == FieldType.signature &&
//           widget.form.fields[index].controller.isEmpty) ||
//       (widget.form.fields[index].type == FieldType.int &&
//           widget.form.fields[index].intValue >= 0);
//
//   Future<bool> _onWillPop() async {
//     _autoSave();
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool writeHeader = false;
//     bool writeGradeSecHeader = false;
//     bool writeSpace = false;
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: WillPopScope(
//         onWillPop: _onWillPop,
//         child: Scaffold(
//           appBar: AppBar(
//             leading: BackButton(color: Colors.white),
//             elevation: 0,
//             backgroundColor: kPrimary,
//             title: Text(
//               widget.form.formName,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             actions: [
//               TextButton(
//                 child: const Text(
//                   'Preview',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 onPressed: () async {
//                   // _submitForm();
//                   await _autoSave(showLoad: true);
//                   await context.read<Pdf>().lunchPdf(widget.form);
//                   setState(() {});
//                 },
//               ),
//               TextButton(
//                 child: const Text(
//                   'Submit',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 onPressed: () async {
//                   await _submitForm(context);
//                   setState(() {});
//                   // await context.read<Pdf>().gen(widget.form);
//                 },
//               )
//             ],
//           ),
//           body: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               formProgress(),
//               Expanded(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Scrollbar(
//                           child: ListView.builder(
//                               itemCount: widget.form.fields.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 Field field = widget.form.fields[index];
//                                 Field previousField;
//                                 if (index == 0) {
//                                   previousField = widget.form.fields[index];
//                                 } else {
//                                   previousField = widget.form.fields[index - 1];
//                                 }
//
//                                 if (field.input) {
//                                   if (index == 0 ||
//                                       (index > 0 &&
//                                           field.section >
//                                               previousField.section)) {
//                                     writeHeader = true;
//                                   } else {
//                                     writeHeader = false;
//                                     if (index > 0 &&
//                                         field.subSection >
//                                             previousField.subSection) {
//                                       writeSpace = true;
//                                     } else {
//                                       writeSpace = false;
//                                     }
//                                   }
//                                   if (index > 0 &&
//                                       field.gradeSection >
//                                           previousField.gradeSection) {
//                                     writeGradeSecHeader = true;
//                                   } else {
//                                     writeGradeSecHeader = false;
//                                   }
//                                   return Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       writeHeader &&
//                                               widget.form.sectionLabel != null
//                                           ? sectionLabel(field)
//                                           : SizedBox.shrink(),
//                                       writeSpace
//                                           ? subSectionDivide()
//                                           : SizedBox.shrink(),
//                                       writeGradeSecHeader &&
//                                               widget.form.gradeSectionLabel !=
//                                                   null
//                                           ? gradeSectionLabel(field)
//                                           : SizedBox.shrink(),
//                                       formField(index, field, context),
//                                       SizedBox(height: 8),
//                                     ],
//                                   );
//                                 } else {
//                                   return const SizedBox.shrink();
//                                 }
//                               }),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Container formProgress() {
//     return Container(
//       height: 35,
//       color: kSecondary,
//       padding: EdgeInsets.symmetric(horizontal: 18),
//       child: Stack(
//         children: [
//           Center(
//             child: Text(
//               '${widget.form.filledRequired()} / ${widget.form.allRequired()}',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//           widget.form.filledRequired() < widget.form.allRequired()
//               ? Align(
//                   alignment: Alignment.centerRight,
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     constraints: BoxConstraints(),
//                     icon: Icon(toggleMandatory
//                         ? Icons.pageview
//                         : Icons.pageview_outlined),
//                     iconSize: 30,
//                     onPressed: () {
//                       setState(() {
//                         toggleMandatory = !toggleMandatory;
//                       });
//                     },
//                   ),
//                 )
//               : SizedBox.shrink(),
//         ],
//       ),
//     );
//   }
//
//   Container formField(int index, Field field, BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
//       decoration: BoxDecoration(
//         color: !toggleMandatory
//             ? Colors.transparent
//             : isMandatoryEmpty(index)
//                 ? Colors.redAccent
//                 : Colors.transparent,
//         border: Border.all(
//             color: !toggleMandatory
//                 ? Colors.black26
//                 : isMandatoryEmpty(index)
//                     ? Colors.red
//                     : Colors.black26),
//         borderRadius: BorderRadius.all(Radius.circular(5.0)),
//       ),
//       child: boxContainer(
//         fieldType: field.type,
//         children: [
//           Row(
//             children: [
//               Text(
//                 field.label,
//                 style: label(),
//                 overflow: TextOverflow.fade,
//               ),
//               field.type == FieldType.checkbox
//                   ? Text(
//                       '   (you can select more than 1 answer)',
//                       style: subLabel(),
//                       overflow: TextOverflow.fade,
//                     )
//                   : SizedBox.shrink()
//             ],
//           ),
//           spacer(fieldType: field.type),
//           valueContainer(
//             fieldType: field.type,
//             child: field.type == FieldType.signature
//                 // ? signaturePad(index)
//                 ? SignaturePad(
//                     // form: widget.form,
//                     // index: index,
//                     field: field,
//                     onSave: _autoSave,
//                   )
//                 : field.type == FieldType.radio
//                     ? radioButtonChoices(index)
//                     : field.type == FieldType.checkbox
//                         ? checkBoxChoices(index)
//                         : field.type == FieldType.date
//                             ? dateInput(index, context)
//                             : field.maxLength != null && field.maxLength! > 100
//                                 ? textForm(index)
//                                 : textField(index),
//           ),
//           // SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
//
//   Column subSectionDivide() {
//     return Column(
//       children: [
//         SizedBox(height: 2),
//         Center(child: Text('---------', style: label())),
//         SizedBox(height: 10),
//       ],
//     );
//   }
//
//   Column sectionLabel(Field field) {
//     return Column(
//       children: [
//         field.section > 1
//             ? Column(
//                 children: [SizedBox(height: 30)],
//               )
//             : SizedBox.shrink(),
//         Text(
//           '  ${widget.form.sectionLabel![field.section - 1]}',
//           style: header(),
//         ),
//         SizedBox(height: 8),
//       ],
//     );
//   }
//
//   Column gradeSectionLabel(Field field) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         field.gradeSection > 1
//             ? Column(
//                 children: [SizedBox(height: 20)],
//               )
//             : SizedBox.shrink(),
//         Text(
//           '  ${widget.form.gradeSectionLabel![field.gradeSection - 1]}',
//           style: subHeader(),
//         ),
//         SizedBox(height: 6),
//       ],
//     );
//   }
//
//   ///To input date as date picker
//   Widget dateInput(int index, BuildContext c) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: TextButton(
//         // child: Text(widget.form.fields[index].stringValue),
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black12, width: 1.3),
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             color: Colors.transparent,
//           ),
//           child: Text(widget.form.fields[index].stringValue, style: value()),
//         ),
//         onPressed: () async {
//           showDialog(
//             context: c,
//             builder: (_) => datePicker(index),
//           );
//         },
//       ),
//     );
//   }
//
//   AlertDialog datePicker(int index) {
//     return AlertDialog(
//       // title: Text(widget.form.fields[index].label, style: label()),
//       backgroundColor: Colors.white,
//       elevation: 0,
//       content: Container(
//         width: 400,
//         height: 400,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(5)),
//         ),
//         child: Center(
//           child: SfDateRangePicker(
//             selectionTextStyle: TextStyle(
//               color: Colors.red,
//               fontWeight: FontWeight.w900,
//               fontSize: 24,
//             ),
//
//             selectionRadius: 0,
//             // selectionShape: DateRangePickerSelectionShape.rectangle,
//             // selectionColor: Colors.transparent,
//             onSelectionChanged: (args) {
//               setState(() {
//                 widget.form.fields[index].dateTimeValue = args.value;
//                 widget.form.fields[index].stringValue =
//                     DateFormat('dd/MM/yyyy').format(args.value);
//               });
//             },
//             initialSelectedDate: widget.form.fields[index].dateTimeValue,
//             // initialSelectedRange: PickerDateRange(
//             //     DateTime.now().subtract(const Duration(days: 4)),
//             //     DateTime.now().add(const Duration(days: 3))),
//           ),
//         ),
//       ),
//     );
//   }
//
//   TextFormField textForm(int index) {
//     return TextFormField(
//       enabled: widget.form.fields[index].input,
//       controller: TextEditingController()
//         ..text = widget.form.fields[index].stringValue,
//       maxLines: widget.form.fields[index].maxLine ?? 5,
//       maxLength: widget.form.fields[index].maxLength,
//       onChanged: (text) => widget.form.fields[index].stringValue = text,
//       onEditingComplete: () => _autoSave(),
//       onSaved: (value) => _autoSave(),
//       decoration: textInputDecor(),
//       style: value(),
//     );
//   }
//
//   Widget textField(int index) {
//     return TextField(
//       key: Key('${widget.form.id}${widget.form.fields[index].name}'),
//       keyboardType: widget.form.fields[index].keyboardType,
//       textCapitalization: widget.form.fields[index].textCapitalization,
//       enabled: widget.form.fields[index].input,
//       controller: TextEditingController()
//         ..text = widget.form.fields[index].stringValue,
//       maxLength: widget.form.fields[index].maxLength,
//       onChanged: (text) => widget.form.fields[index].stringValue = text,
//       onSubmitted: (text) {
//         _autoSave();
//         setState(() {});
//       },
//       decoration: textInputDecor(),
//       textAlign: TextAlign.end,
//       style: value(),
//     );
//   }
//
//   Widget radioButtonChoices(int index) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       reverse: true,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           for (int radio = 0;
//               radio < widget.form.fields[index].listValue.length;
//               radio++)
//             Row(
//               children: [
//                 GestureDetector(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                           color: widget.form.fields[index].intValue == radio
//                               ? kSecondaryDarker
//                               : Colors.black12,
//                           width: 1.3),
//                       borderRadius: BorderRadius.all(Radius.circular(8)),
//                       color: widget.form.fields[index].intValue == radio
//                           ? kSecondary
//                           : Colors.transparent,
//                     ),
//                     child: Text(widget.form.fields[index].listValue[radio],
//                         style: value()),
//                   ),
//                   onTap: () {
//                     setState(() {
//                       if (widget.form.fields[index].intValue != radio) {
//                         widget.form.fields[index].intValue = radio;
//                         widget.form.fields[index].stringValue =
//                             widget.form.fields[index].listValue[radio];
//                       } else {
//                         widget.form.fields[index].intValue = -1;
//                         widget.form.fields[index].stringValue = '';
//                       }
//                       _autoSave();
//                     });
//                   },
//                 ),
//                 SizedBox(width: 5),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget checkBoxChoices(int index) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       reverse: true,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           for (int checkIndex = 0;
//               checkIndex < widget.form.fields[index].checkBoxValue.length;
//               checkIndex++)
//             Row(
//               children: [
//                 GestureDetector(
//                   child: Container(
//                     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                           color: widget
//                                   .form.fields[index].checkBoxValue[checkIndex]
//                               ? kSecondaryDarker
//                               : Colors.black12,
//                           width: 1.3),
//                       borderRadius: BorderRadius.all(Radius.circular(8)),
//                       color: widget.form.fields[index].checkBoxValue[checkIndex]
//                           ? kSecondary
//                           : Colors.transparent,
//                     ),
//                     child: Text(widget.form.fields[index].listValue[checkIndex],
//                         style: value()),
//                   ),
//                   onTap: () {
//                     setState(() {
//                       widget.form.fields[index].checkBoxValue[checkIndex] =
//                           !widget.form.fields[index].checkBoxValue[checkIndex];
//                       String _name = widget.form.fields[index].name +
//                           '_' +
//                           checkIndex.toString();
//                       print(_name);
//                       widget
//                               .form
//                               .fields[widget.form.fields
//                                   .indexWhere((e) => e.name == _name)]
//                               .stringValue =
//                           widget.form.fields[index].checkBoxValue[checkIndex]
//                               .toString();
//                       print(widget
//                           .form
//                           .fields[widget.form.fields
//                               .indexWhere((e) => e.name == _name)]
//                           .stringValue);
//
//                       // if (widget.form.fields[index].intValue != checkIndex) {
//                       //   widget.form.fields[index].intValue = checkIndex;
//                       //   widget.form.fields[index].stringValue =
//                       //       widget.form.fields[index].listValue[checkIndex];
//                       // } else {
//                       //   widget.form.fields[index].intValue = -1;
//                       //   widget.form.fields[index].stringValue = '';
//                       // }
//                       _autoSave();
//                     });
//                   },
//                 ),
//                 SizedBox(width: 5),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
//
// // Widget signaturePad(int index) {
// //   return Column(
// //     crossAxisAlignment: CrossAxisAlignment.start,
// //     children: [
// //       // Text(widget.form.fields[_index].label),
// //       //SIGNATURE CANVAS
// //       widget.form.fields[index].signature != null
// //           ? Image.memory(
// //               Uint8List.fromList(widget.form.fields[index].signature!))
// //           : SizedBox.shrink(),
// //       ClipRRect(
// //         child: SizedBox(
// //           // height: 180,
// //           child: Signature(
// //             controller: widget.form.fields[index].controller,
// //             height: 180,
// //             // width: 390,
// //             backgroundColor: Color(0xffeeeeee),
// //           ),
// //         ),
// //       ),
// //       //OK AND CLEAR BUTTONS
// //       Container(
// //         decoration: const BoxDecoration(color: kPrimaryDarker),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //           mainAxisSize: MainAxisSize.max,
// //           children: <Widget>[
// //             //SHOW EXPORTED IMAGE IN NEW ROUTE
// //             IconButton(
// //               icon: const Icon(Icons.save),
// //               color: kSecondary,
// //               onPressed: () async {
// //                 await widget.form.fields[index]
// //                     .convertSignature((String response) async {
// //                   if (response == kStatusSuccess) {
// //                     await _autoSave();
// //                   } else {
// //                     Snackbar.show(context,
// //                         text: 'Please sign your signature',
// //                         type: Type.error,
// //                         isFixed: false);
// //                   }
// //                 });
// //                 setState(() {});
// //               },
// //             ),
// //             IconButton(
// //               icon: const Icon(Icons.undo),
// //               color: kSecondary,
// //               onPressed: () async {
// //                 setState(() => widget.form.fields[index].controller.undo());
// //                 // widget.form.fields[index].sigStore();
// //                 // await _autoSave();
// //               },
// //             ),
// //             IconButton(
// //               icon: const Icon(Icons.redo),
// //               color: kSecondary,
// //               onPressed: () async {
// //                 setState(() => widget.form.fields[index].controller.redo());
// //                 // widget.form.fields[index].sigStore();
// //                 // await _autoSave();
// //               },
// //             ),
// //             //CLEAR CANVAS
// //             IconButton(
// //               icon: const Icon(Icons.delete),
// //               color: kSecondary,
// //               onPressed: () {
// //                 setState(() {
// //                   widget.form.fields[index].controller.clear();
// //                   // widget.form.fields[index].signature = null;
// //                 });
// //                 _autoSave();
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     ],
// //   );
// // }
// }
