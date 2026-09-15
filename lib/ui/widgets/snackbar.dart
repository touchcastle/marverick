import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marverick/ui/widgets/scroll_text.dart';
import 'package:marverick/services/log.dart';

enum Type {
  info,
  caution,
  error,
}

class Snackbar {
  static void show(
    BuildContext context, {
    required String text,
    Type type = Type.error,
    bool isFixed = false,
    int? duration,
  }) {
    // Guarantee the message actually shown to the user lands in the log,
    // regardless of whether the call site also logged its own reason —
    // upstream code has repeatedly forgotten to (e.g. the missing-required-
    // fields path in FormSubmission.submit never called Log.add), leaving
    // "Send Log" with nothing to show for the error the user just saw.
    if (type != Type.info) {
      Log.add('SNACKBAR (${type.name}): $text');
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: isFixed ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
      // elevation: 0,
      backgroundColor: type == Type.info
          ? Colors.green.shade700
          : type == Type.caution
              ? Colors.orangeAccent
              : Colors.red,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          type == Type.info
              ? SizedBox.shrink()
              : type == Type.caution
                  ? Icon(Icons.warning, color: Colors.white)
                  : Icon(Icons.error, color: Colors.white),
          SizedBox(width: 5),
          Expanded(child: ScrollingText(text: text)),
          SizedBox(width: 5),
          type == Type.error
              ? TextButton(
                  onPressed: () async {
                    await Log.send();
                  },
                  child: Text('Send Log'))
              : SizedBox.shrink(),
        ],
      ),
      duration: duration != null
          ? Duration(seconds: duration)
          : type == Type.info
              ? const Duration(seconds: 3)
              : const Duration(seconds: 10),
    ));
  }
}
