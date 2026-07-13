import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marverick/ui/views/main_menu.dart';
import 'package:provider/provider.dart';
import 'package:marverick/services/form_service.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/ui/views/log_in.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/utils/utils.dart';

class Landing extends StatefulWidget {
  static const id = kLandingId; //for route.

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  ///Initialize app's variables
  void _appInitialize() async {
    // Authen.user must be populated (and Firebase Auth's session restore
    // actually finished, not just checked) before loading forms —
    // loadFromDatabase scopes the local query to the signed-in account, so
    // running it against a not-yet-resolved Authen.user would show an empty
    // or wrongly-scoped list even though the data is still safely on disk.
    await Authen.getCurrentUser();
    //Query stored form from database
    await context.read<FormService>().loadFromDatabase();
    await Future.delayed(const Duration(milliseconds: 1500));
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        settings: RouteSettings(
            name: Authen.user != null ? kMainPageName : kLoginPageName),
        transitionDuration: kLandingTransitionDur,
        transitionsBuilder: kPageTransition,
        pageBuilder: (_, __, ___) =>
            Authen.user != null ? MainMenu() : Login()));
  }

  @override
  void initState() {
    Utils.context = context;
    _appInitialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return const Scaffold(
      backgroundColor: kPrimary,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Center(
          child: SizedBox.shrink(),
          // child: Hero(
          //   tag: kHeroLogo,
          //   child: SizedBox(
          //     width: width * 0.75,
          //     child: const Image(
          //       image: AssetImage(kLogoImage),
          //     ),
          //   ),
          // ),
        ),
      ),
    );
  }
}
