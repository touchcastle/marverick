import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/services/authen.dart';

class Utils {
  static BuildContext? context;

  static void showInProgress(bool inProgress) async {
    if (inProgress) {
      EasyLoading.show(
        status: 'Loading...',
        maskType: EasyLoadingMaskType.black,
      );
    } else {
      EasyLoading.dismiss();
    }
  }

  // static bool isAdmin() =>
  //     Authen.user.email == kAdminMail || Authen.user.email == kBeamMail;
}
