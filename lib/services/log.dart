import 'package:intl/intl.dart';
import 'package:marverick/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class Log {
  static List<String> log = [];

  /// Keep only the most recent entries — an unbounded session-lifetime log
  /// buries the actual error under old, unrelated history, and a long body
  /// risks silent truncation by the mailto composer in [send] (which would
  /// cut off the end — i.e. the most recent, most relevant entries — first).
  static const int _maxEntries = 300;

  static void clear() => log.clear();

  static void add(String text) {
    final time = DateFormat('kk:mm:ss').format(DateTime.now());
    log.add('[$time] $text');
    if (log.length > _maxEntries) {
      log.removeRange(0, log.length - _maxEntries);
    }
  }

  static Future send() async {
    String date =
        DateFormat('dd MMM yyyy').format(DateTime.now()).toUpperCase();
    String time = DateFormat('kk:mm:ss').format(DateTime.now());

    String encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    // Log entries can contain '&', '#', '%', newlines, etc. (exception text
    // especially) — those must go through Uri.encodeComponent, not straight
    // into a hand-built string, or the mailto URI silently breaks/truncates
    // right at the first special character.
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: kAdminEmail,
      query: encodeQueryParameters(<String, String>{
        'subject': '$date $time FormServe Log',
        'body': Log.log.join('\n'),
      }),
    );
    await launchUrl(emailLaunchUri);
  }
}
