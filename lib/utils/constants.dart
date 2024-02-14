import 'package:flutter/material.dart';
import 'package:marverick/models/form.dart';
import 'package:marverick/ui/views/file_list.dart';

///Version number
const String kVersion = '1.3.3';

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
const String kRt5Table = 'rt5_table';
const List<String> kDbTableList = [
  'line_check_table',
  'ppc_table',
  'rt5_table',
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
const String kTjoMail = 'teerachart.jo@vietjetair.com';
const String kLineChekSheetUrl =
    "https://script.google.com/macros/s/AKfycbwteVnV0IZq-R4a_c6EyM9d4ucL-PriLZLlKdzr2-M56w8-DMA/exec";
const String kPPCSheetUrl =
    "https://script.google.com/macros/s/AKfycbz8y3I6TpZAEdaG0PC1IZ2HwxyqgkbNN95Qnf2QUAcKWQ_eePlY1lcTXYvu2Vne6Jgt1A/exec";
const String kRt5SheetUrl =
    "https://script.google.com/macros/s/AKfycbyJYqi4u1gckKSMOzDv-cAVmphX3WAPRUDfmXSYmCs1xymbdOWTK-EJb-L-Kgu1gNq2cg/exec";

const String kSampleMail = 'sample';
const String kSamplePassword = 'qwerty';
// const String kBeamMail = 'beamtjo';
// const String kBeamPassword = 'qwerty';

///Decoration
BoxDecoration fileBoxDecor(FormStatus status) {
  return BoxDecoration(
    color: status == FormStatus.working
        ? Color(0xfffce19d).withOpacity(1)
        : status == FormStatus.completed
            ? Colors.black12
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
