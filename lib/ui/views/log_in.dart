import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/ui/views/main_menu.dart';
import 'package:marverick/ui/widgets/snackbar.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/utils/utils.dart';

class Login extends StatefulWidget {
  static const id = kLoginId; //for route.
  bool fromInside;

  Login({this.fromInside = false});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = '';
  String password = '';
  final double inputAreaWidth = 400;
  late StreamSubscription<ConnectivityResult> subscription;
  bool noInternet = false;

  void connectivity() async {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        if (await Connectivity().checkConnectivity() ==
            ConnectivityResult.none) {
          setState(() {
            noInternet = true;
          });
        } else {
          setState(() {
            noInternet = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    Utils.context = context;
    connectivity();
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  InputDecoration decor(String hintText) {
    return InputDecoration(
      fillColor: Color(0xffeeeeee),
      filled: true,
      hintText: hintText,
      isCollapsed: true,
      contentPadding: EdgeInsets.all(10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future resetPassword() async {
    try {
      if(email == ''){
        Snackbar.show(context, text: 'Please input username / email');
      } else {
        Utils.showInProgress(true);
        await Authen.resetPassword(email);
        Utils.showInProgress(false);
        FocusManager.instance.primaryFocus?.unfocus();
        Snackbar.show(context, text: 'Password reset email was sent. Please check your inbox.', type: Type.info);
      }
    } catch (e) {
      Utils.showInProgress(false);
      FocusManager.instance.primaryFocus?.unfocus();
      Snackbar.show(context, text: '$e');
      // if (widget.fromInputPage) Navigator.of(context).pop();
    }
  }

  Future loginAndNavigate() async {
    try {
      Utils.showInProgress(true);
      await Authen.signIn(email, password);
      Utils.showInProgress(false);
      if (Authen.user != null) {
        if (widget.fromInside) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              settings: RouteSettings(name: kMainPageName),
              // transitionDuration: kLandingTransitionDur,
              // transitionsBuilder: kPageTransition,
              pageBuilder: (_, __, ___) => MainMenu(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              settings: RouteSettings(name: kMainPageName),
              transitionDuration: kLandingTransitionDur,
              transitionsBuilder: kPageTransition,
              pageBuilder: (_, __, ___) => MainMenu(),
            ),
          );
        }
      } else {
        Snackbar.show(context, text: 'Login error');
        // if (widget.fromInputPage) Navigator.of(context).pop();
      }
    } catch (e) {
      Utils.showInProgress(false);
      Snackbar.show(context, text: '$e');
      // if (widget.fromInputPage) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: widget.fromInside,
        backgroundColor: kPrimary,
        actionsIconTheme: IconThemeData(color: Colors.white),
        // title: const Text('Choose PDF to create'),
      ),
      backgroundColor: kPrimary,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: inputAreaWidth,
                      // height: 400,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) => email = value,
                              decoration: decor('username'),
                            ),
                            SizedBox(height: 10),
                            TextField(
                              obscureText: true,
                              onChanged: (value) => password = value,
                              decoration: decor('password'),
                            ),
                            SizedBox(height: 40),
                            Container(
                              width: inputAreaWidth,
                              // width: MediaQuery.of(context).size.width),
                              height: 40,
                              decoration: const BoxDecoration(
                                color: kSecondary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25)),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  loginAndNavigate();
                                },
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            TextButton(
                              onPressed: () async {
                                resetPassword();
                              },
                              child: Text(
                                'Reset password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14),
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
            noInternet & !widget.fromInside
                ? TextButton(
                    child: Text(
                      'Offline Mode',
                      style: TextStyle(
                        color: kSecondary,
                        // fontWeight: FontWeight.normal,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(PageRouteBuilder(
                          settings: RouteSettings(name: kMainPageName),
                          transitionDuration: kLandingTransitionDur,
                          transitionsBuilder: kPageTransition,
                          pageBuilder: (_, __, ___) =>
                              MainMenu(isOfflineMode: true)));
                    },
                  )
                : SizedBox.shrink(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
