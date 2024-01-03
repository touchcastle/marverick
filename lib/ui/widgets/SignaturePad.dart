import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:typed_data';
import 'package:signature/signature.dart';
import 'package:marverick/models/field.dart';
import 'package:marverick/ui/widgets/snackbar.dart';
import 'package:marverick/utils/constants.dart';

class SignaturePad extends StatefulWidget {
  // f.Form form;
  // int index;
  Field field;
  VoidCallback onSave;
  Function callback;

  SignaturePad({
    required this.callback,
    required this.field,
    required this.onSave,
  });

  // SignaturePad({required this.form, required this.index, required this.onSave});

  @override
  _SignaturePadState createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.field.signature != null
            ? Image.memory(
                Uint8List.fromList(widget.field.signature!),
                gaplessPlayback: true,
              )
            : SizedBox.shrink(),
        ClipRRect(
          child: SizedBox(
            // height: 180,
            child: Signature(
              controller: widget.field.controller,
              height: 180,
              // width: 390,
              backgroundColor: Color(0xffeeeeee),
            ),
          ),
        ),
        //OK AND CLEAR BUTTONS
        Container(
          decoration: const BoxDecoration(color: kPrimaryDarker),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //SHOW EXPORTED IMAGE IN NEW ROUTE
              IconButton(
                icon: const Icon(Icons.save),
                color: kSecondary,
                onPressed: () async {
                  this.widget.callback();
                  await widget.field.convertSignature((String response) async {
                    setState(() {
                      if (response == kStatusSuccess) {
                        widget.onSave;
                      } else {
                        Snackbar.show(
                          context,
                          text: 'Please sign your signature',
                          type: Type.error,
                          isFixed: false,
                        );
                      }
                    });
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                color: kSecondary,
                onPressed: () async {
                  setState(() => widget.field.controller.undo());
                  // widget.form.fields[index].sigStore();
                  // await _autoSave();
                },
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                color: kSecondary,
                onPressed: () async {
                  setState(() => widget.field.controller.redo());
                  // widget.form.fields[index].sigStore();
                  // await _autoSave();
                },
              ),
              //CLEAR CANVAS
              IconButton(
                icon: const Icon(Icons.delete),
                color: kSecondary,
                onPressed: () {
                  setState(() {
                    widget.field.controller.clear();
                    // widget.form.fields[index].signature = null;
                  });
                  widget.onSave;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
