import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/services/authen.dart';

class Utils {
  static BuildContext? context;

  static bool isIpad = true;

  static Future<bool> checkIpad() async {
    // deviceInfo.iosInfo throws on non-iOS platforms — an Android device is
    // never an iPad, so short-circuit rather than call the iOS-only API.
    if (!Platform.isIOS) {
      isIpad = false;
      return false;
    }
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    if (info.model.toLowerCase().contains("ipad")) {
      isIpad = true;
      return true;
    }
    isIpad = false;
    return false;
  }

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
