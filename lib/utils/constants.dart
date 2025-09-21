import 'package:flutter/material.dart';
import 'package:marverick/models/form.dart';
import 'package:marverick/ui/views/file_list.dart';

///=============================================================================
/// Version No.   Date          Description
/// 1.9.3         20.08.2025    - Fix bug form name not correct date.
/// 1.10.0        28.08.2025    - Add new form: [Standard LOFT].
/// 1.11.0        21.09.2025    - Update form version [LINE TRAIN/CHK ver15].
///
///=============================================================================

///Version number
const String kVersion = '1.11.0';

///PageID
const String kLandingId = 'landing_screen';
const String kMainMenuId = 'main_menu';
// const String kCompletedId = 'completed';
// const String kPendingId = 'pending';
const String kFormListId = 'working';
const String kLoginId = 'login';
const String kInputId = 'input';

///PageName
const String kMainPageName = '/main_menu_page';
const String kLoginPageName = '/loin_page';
const String kInputPageName = '/input_page';

/// Database name and Table name.
const String kDbName = 'formServeDb.db'; //Database name
const String kLineCheckTable = 'line_check_table';
const String kPPCTable = 'ppc_table';
const String kPPC5Table = 'ppc5_table';
const String kPPC6Table = 'ppc6_table';
const String kRt1Table = 'rt1_table';
const String kRt2Table = 'rt2_table';
const String kRt22Table = 'rt22_table';
const String kStdloftTable = 'stdloft_table';
const String kRt5Table = 'rt5_table';
const String kRt6Table = 'rt6_table';
const String kLineTrainTable = 'line_train_table';
const String kCccTable = 'ccc_table';
const String kPscTable = 'psc_table';
const List<String> kDbTableList = [
  'line_check_table',
  'ppc_table',
  'ppc5_table',
  'ppc6_table',
  'rt1_table',
  'rt2_table',
  'rt22_table',
  'stdloft_table',
  'rt5_table',
  'rt6_table',
  'line_train_table',
  'ccc_table',
  'psc_table',
];

List<Widget> widgetOptions = <Widget>[
  FormList(status: FormStatus.completed),
  FormList(status: FormStatus.pending),
  FormList(status: FormStatus.working),
];

enum ErrorType {
  success,
  missingRequired,
  noInternet,
  other,
  validate,
}

///animation
const Duration kLandingTransitionDur = Duration(milliseconds: 1000);

///Page Transition
const String kHeroLogo = 'logo';
const String kLogoImage = 'assets/images/logo.png';
RouteTransitionsBuilder kPageTransition =
    (context, animation, secondaryAnimation, child) {
  // const begin = Offset(1.0, 0.0);  //From center-right
  const begin = Offset(0.0, 1.0); //From center-bottom
  const end = Offset.zero;
  const curve = Curves.ease;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
};

///Setting
const double kTabletStartWidth = 600.0;
const int kInitChoice = -1;
const Color kPrimary = Color(0xffe4232a);
const Color kPrimaryAccent = Color(0xffea202d);
const Color kPrimaryDarker = Color(0xffc11823);
const Color kSecondary = Color(0xfffedc32);
const Color kSecondaryDarker = Color(0xffebb92f);
const Color kPenColor = Color(0xff000F55);
const String kStatusSuccess = 'SUCCESS';
const String kStatusError = 'ERROR';
const String kAdminMail = 'admin@vietjetair.com';
const String kTjoMail = 'teerachart.j@gmail.com';
const String kLineChekSheetUrl =
    "https://script.google.com/macros/s/AKfycbwteVnV0IZq-R4a_c6EyM9d4ucL-PriLZLlKdzr2-M56w8-DMA/exec";
const String kPPCSheetUrl =
    "https://script.google.com/macros/s/AKfycbz8y3I6TpZAEdaG0PC1IZ2HwxyqgkbNN95Qnf2QUAcKWQ_eePlY1lcTXYvu2Vne6Jgt1A/exec";
const String kPPC5SheetUrl =
    "https://script.google.com/macros/s/AKfycbyjXvXQ2PpTxksZ4WSaqqL2OBZkf3zxwAzbht7opSPhoDBgyl9PTbz1gYO7IXbv-8yABA/exec";
const String kPPC6SheetUrl =
    "https://script.google.com/macros/s/AKfycbx0xpbZiQQ7JYGXAtMUZemP4BWbS0Sila0QkxiypKadW9f8-HqnDPKdBzV_2BLddRK1/exec";
const String kRt1SheetUrl =
    "https://script.google.com/macros/s/AKfycbzJn79oV2eX_lIavKZQNK-XJ_j5CNlJKG6DG23ugZ87j5wBrwCMRbtDwG2ZLn2Ed6vUUw/exec";
const String kRt2SheetUrl =
    "https://script.google.com/macros/s/AKfycby5iYo_sJdyPfKrv_PMuqSSn8wROycmxB7ADcLbDKUpGTPKvh6jKVickMyuJgvv4Wix/exec";
const String kStdloftSheetUrl =
    "https://script.google.com/macros/s/AKfycbypiQrQUaJ-SAGC1J3pBRqB36lo0NZP7EG59krNbeuEc29831wGRBxpE5vCSDOQErrf/exec";
const String kRt22SheetUrl =
    "https://script.google.com/macros/s/AKfycbzLvZZ1ueJ4S9KsFptnbCk19IPMdpjdqLoXn7C2eKdIYVqEFB2ZNLgpSzOZqUcFCKjB/exec";
const String kRt5SheetUrl =
    "https://script.google.com/macros/s/AKfycbyJYqi4u1gckKSMOzDv-cAVmphX3WAPRUDfmXSYmCs1xymbdOWTK-EJb-L-Kgu1gNq2cg/exec";
const String kRt6SheetUrl =
    "https://script.google.com/macros/s/AKfycbwEsW4ET4tUVciS2gap91ryhWGTWr9ZWobT2dQuE7nypxg_NDWjlcjK647PYZCt1Ib70w/exec";
const String kLineTrainSheetUrl =
    "https://script.google.com/macros/s/AKfycbynCthDqbLzUwv0rh3aaJY6knx4JiVOfE-Mh36wReCNYkyys1jNt_V1RqKnu1oHnv1y8A/exec";
const String kCccSheetUrl =
    "https://script.google.com/macros/s/AKfycbzQVesyQtUt6nHc4Yr1njkTfeeK3aC-Gh6SHxA8MY7r1FZL-WtsTRBrBH5qx7C64O1WcA/exec";
const String kPscSheetUrl =
    "https://script.google.com/macros/s/AKfycbz4j9ackoBVrtHktlWTXxLBYHShwWb724A5rL6UyywG3i-7qlDFR-6U4p5_ZEHMQ2rhHw/exec";
const String kSampleMail = 'sample';
const String kSamplePassword = 'qwerty';
const String kBlankText = '          ';
// const String kBeamMail = 'beamtjo';
// const String kBeamPassword = 'qwerty';
const Duration kSubmitTimeout = Duration(seconds: 15);
const String kAdminEmail = 'teerachart.j@gmail.com';
final DateTime kFirstMay25 = DateTime.parse('2025-05-01 00:00:00.000');
final DateTime kFirstJune25 = DateTime.parse('2025-06-01 00:00:00.000');
final DateTime kFirstJuly25 = DateTime.parse('2025-07-01 00:00:00.000');
final DateTime k28July25 = DateTime.parse('2025-07-28 00:00:00.000');

///Decoration
BoxDecoration fileBoxDecor(FormStatus status) {
  return BoxDecoration(
    color: status == FormStatus.working
        ? Color(0xfffce19d).withOpacity(1)
        : status == FormStatus.completed
            ? Color(0xffdadada)
            : Color(0xfff7b7b7),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    // backgroundBlendMode: ,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 2,
        blurRadius: 2,
        offset: Offset(4, 3), // changes position of shadow
      ),
    ],
  );
}

InputDecoration textInputDecor() {
  return InputDecoration(
    counterText: '',
    fillColor: Color(0xffeeeeee),
    filled: true,
    isCollapsed: true,
    contentPadding: EdgeInsets.all(10),
    prefixIconColor: kPrimary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
