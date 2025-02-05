import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:marverick/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class Log {
  static List<String> log = [];

  static void clear() => log.clear();

  static void add(String text) {
    // String date =
    //     DateFormat('dd MMM yyyy').format(DateTime.now()).toUpperCase();
    // String time = DateFormat('kk:mm:ss').format(DateTime.now());
    log.add(text);
  }

  static Future send() async {
    String date =
        DateFormat('dd MMM yyyy').format(DateTime.now()).toUpperCase();
    String time = DateFormat('kk:mm:ss').format(DateTime.now());

    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: kAdminEmail,
      query: encodeQueryParameters(<String, String>{
        'subject': '$date $time FormServe Log',
        'body': 'body body jaa',
      }),
    );
    await launchUrl(Uri.parse(
        "mailto:$kAdminEmail?subject='$date $time Formserve Log&body='${Log.log.join(', ')}'"));
    print('send');
    launchUrl(emailLaunchUri);

    // final Email email = Email(
    //   subject: '$date $time Formserve Log',
    //   body: Log.log.join(', '),
    //   recipients: [kAdminEmail],
    //   isHTML: false,
    // );
    //
    // await FlutterEmailSender.send(email);
  }
}
