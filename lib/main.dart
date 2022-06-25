import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marverick/services/pdf.dart';
import 'package:marverick/services/form_service.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/services/database.dart';
import 'package:marverick/ui/views/landing.dart';
import 'package:marverick/ui/views/log_in.dart';
import 'package:marverick/utils/constants.dart';

void main() async {
  /// Database initialization and query.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Pdf pdf = Pdf();
  Authen authen = Authen();
  FormService service = FormService(authen: authen, pdf: pdf);
  var provider = MultiProvider(
    providers: [
      Provider<Pdf>(create: (_) => pdf),
      ListenableProvider<FormService>(create: (_) => service),
      Provider<Authen>(create: (_) => authen),
      // ListenableProvider<Pdf>(create: (_) => pdf),
    ],
    child: Marverick(),
  );
  void configLoading() {
    EasyLoading.instance
      // ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.wave
      ..loadingStyle = EasyLoadingStyle.custom
      // ..indicatorSize = 45.0
      // ..radius = 10.0
      ..progressColor = kPrimary
      ..backgroundColor = kSecondaryDarker
      ..indicatorColor = kPrimaryDarker
      ..textColor = kPrimaryDarker;
  }

  await DatabaseService.openDB();
  runApp(provider);
  configLoading();
}

class Marverick extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Landing.id,
      // theme: ThemeData(fontFamily: kPrimaryFontFamily),
      routes: {
        Landing.id: (context) => Landing(),
        Login.id: (context) => Login(),
      },
      builder: EasyLoading.init(),
    );
  }
}
