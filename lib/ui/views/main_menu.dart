import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:marverick/services/form_service.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/ui/views/log_in.dart';
import 'package:marverick/ui/widgets/snackbar.dart';
import 'package:marverick/utils/constants.dart';
import 'package:marverick/utils/utils.dart';
import 'package:upgrader/upgrader.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MainMenu extends StatefulWidget {
  static const id = kMainMenuId; //for route.
  int selectedIndex = 0;
  bool isOfflineMode;

  MainMenu({this.selectedIndex = 0, this.isOfflineMode = false});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late StreamSubscription<ConnectivityResult> subscription;
  bool wasDisconnected = false;

  void _screenInit() async {
    // print(await Connectivity().checkConnectivity());
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      // print(result);

      if (result == ConnectivityResult.none &&
          (await Connectivity().checkConnectivity() ==
              ConnectivityResult.none)) {
        wasDisconnected = true;
        // showOfflineSnackbar();
      } else if (result != ConnectivityResult.none &&
          (await Connectivity().checkConnectivity() !=
              ConnectivityResult.none) &&
          wasDisconnected) {
        wasDisconnected = false;
        Snackbar.show(context,
            text: 'Connection restored.',
            type: Type.info,
            isFixed: true,
            duration: 5);
      }
    });
  }

  void showOfflineSnackbar() async {
    await Future.delayed(const Duration(milliseconds: 500));
    Snackbar.show(context,
        text:
            'NO INTERNET CONNECTION: You can create or edit form while offline.',
        type: Type.info,
        isFixed: true,
        duration: 10);
  }

  @override
  void initState() {
    _screenInit();
    // if (Authen.isSample) context.read<FormService>().forms.clear();
    widget.isOfflineMode ? showOfflineSnackbar() : null;
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // bool rt5Valid() =>
    //     Authen.isAdmin() ||
    //     DateTime.now().isAfter(DateTime.parse('2024-01-01 00:00:00.000'));

    // print('is ipad >> ${Utils.isIpad}');

    String rtText() => DateTime.now().isAfter(kFirstMay25)
        ? 'RECURRENT TRAINING RT1 (rev.01)'
        : 'RECURRENT TRAINING RT1 (rev.00)';

    TextStyle headerL() => TextStyle(
        color: kPrimaryDarker, fontWeight: FontWeight.bold, fontSize: 18);
    TextStyle headerS() => TextStyle(
        color: kPrimaryDarker, fontWeight: FontWeight.bold, fontSize: 14);

    context.read<FormService>().countPending();
    String _pendingLabel = context.watch<FormService>().pendingCount > 0 &&
            !Authen.isSample
        ? 'Pending (${context.watch<FormService>().pendingCount.toString()})'
        : 'Pending';
    String _draftLabel =
        context.watch<FormService>().draftCount > 0 && !Authen.isSample
            ? 'Draft (${context.watch<FormService>().draftCount.toString()})'
            : 'Draft';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Utils.isIpad ? 55 : 40),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kPrimary,
          actions: [
            Container(
              width: 100,
              // color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    Authen.forcingAdmin();
                  });
                },
              ),
            ),
            Authen.user == null
                ? TextButton(
                    child: const Text(
                      'Log In',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      Navigator.of(context).push(PageRouteBuilder(
                          settings: RouteSettings(name: kMainPageName),
                          pageBuilder: (_, __, ___) =>
                              Login(fromInside: true)));
                    },
                  )
                : TextButton(
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (_) => _logOutWithConfirm(),
                      );
                    },
                  ),
            Authen.isAdmin()
                ? TextButton(
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      setState(() {
                        Authen.forceAdmin = 0;
                      });
                    },
                  )
                : SizedBox.shrink(),
          ],
          // title: const Text('Choose PDF to create'),
        ),
      ),
      body: UpgradeAlert(
        upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.cupertino),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: IndexedStack(
                index: widget.selectedIndex, children: widgetOptions),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_done, size: Utils.isIpad ? 24 : 16),
            label: 'Submitted',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload, size: Utils.isIpad ? 24 : 16),
            label: _pendingLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mode_edit, size: Utils.isIpad ? 24 : 16),
            label: _draftLabel,
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: kSecondary,
        backgroundColor: kPrimary,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton: Authen.isSample
          ? FloatingActionButton(
              elevation: 3,
              child: Icon(Icons.add),
              backgroundColor: kPrimaryAccent,
              onPressed: () {
                if (Authen.isSample) {
                  context
                      .read<FormService>()
                      .newForm(context, FormService.initSample());
                } else {
                  context
                      .read<FormService>()
                      .newForm(context, FormService.initLineCheck());
                }
              })
          : SpeedDial(
              buttonSize: Utils.isIpad ? Size(56.0, 56.0) : Size(36.0, 36.0),
              childrenButtonSize:
                  Utils.isIpad ? Size(56.0, 56.0) : Size(36.0, 36.0),
              elevation: 3,
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: kPrimaryAccent,
              spacing: 10,
              spaceBetweenChildren: 1,
              children: [
                // SpeedDialChild(
                //   child: Icon(Icons.add, color: kPrimaryDarker),
                //   label: 'CABIN CREW LINE TRAIN / CHECK',
                //   labelStyle: Utils.isIpad ? headerL() : headerS(),
                //   onTap: () {
                //     context
                //         .read<FormService>()
                //         .newForm(context, FormService.initCcc());
                //   },
                // ),
                // SpeedDialChild(
                //   child: Icon(Icons.add, color: kPrimaryDarker),
                //   label: 'PURSER UPGRADE LINE TRAIN / CHECK',
                //   labelStyle: Utils.isIpad ? headerL() : headerS(),
                //   onTap: () {
                //     context
                //         .read<FormService>()
                //         .newForm(context, FormService.initPsc());
                //   },
                // ),
                SpeedDialChild(
                  child: Icon(Icons.add, color: kPrimaryDarker),
                  label: 'LINE CHECK (SV) (rev.04)',
                  labelStyle: Utils.isIpad ? headerL() : headerS(),
                  onTap: () {
                    context
                        .read<FormService>()
                        .newForm(context, FormService.initLineCheck());
                  },
                ),
                if ((DateTime.now().isBefore(kFirstJuly25)) || Authen.isAdmin())
                SpeedDialChild(
                  child: Icon(Icons.add, color: kPrimaryDarker),
                  label: 'PPC / SKILL TEST (rev.05)',
                  labelStyle: Utils.isIpad ? headerL() : headerS(),
                  onTap: () {
                    context
                        .read<FormService>()
                        .newForm(context, FormService.initPpc5());
                  },
                ),
                if ((DateTime.now().isAfter(kFirstJuly25)) || Authen.isAdmin())
                  SpeedDialChild(
                    child: Icon(Icons.add, color: kPrimaryDarker),
                    label: 'PPC / SKILL TEST (rev.06)',
                    labelStyle: Utils.isIpad ? headerL() : headerS(),
                    onTap: () {
                      context
                          .read<FormService>()
                          .newForm(context, FormService.initPpc6());
                    },
                  ),
                if ((DateTime.now().isBefore(kFirstJuly25)) || Authen.isAdmin())
                  SpeedDialChild(
                    child: Icon(Icons.add, color: kPrimaryDarker),
                    // label: 'RECURRENT TRAINING RT1 (rev.01)',
                    label: rtText(),
                    labelStyle: Utils.isIpad ? headerL() : headerS(),
                    onTap: () {
                      context
                          .read<FormService>()
                          .newForm(context, FormService.initRt1());
                    },
                  ),
                if ((DateTime.now().isBefore(k28July25)) || Authen.isAdmin())
                SpeedDialChild(
                  child: Icon(Icons.add, color: kPrimaryDarker),
                  // label: 'RECURRENT TRAINING RT1 (rev.01)',
                  label: 'RECURRENT TRAINING RT2 (rev.01)',
                  labelStyle: Utils.isIpad ? headerL() : headerS(),
                  onTap: () {
                    context
                        .read<FormService>()
                        .newForm(context, FormService.initRt2());
                  },
                ),
                if ((DateTime.now().isAfter(k28July25)) || Authen.isAdmin())
                  SpeedDialChild(
                    child: Icon(Icons.add, color: kPrimaryDarker),
                    // label: 'RECURRENT TRAINING RT1 (rev.01)',
                    label: 'RECURRENT TRAINING RT2 (rev.02)',
                    labelStyle: Utils.isIpad ? headerL() : headerS(),
                    onTap: () {
                      context
                          .read<FormService>()
                          .newForm(context, FormService.initRt22());
                    },
                  ),
                SpeedDialChild(
                  child: Icon(Icons.add, color: kPrimaryDarker),
                  label: 'LINE TRAIN / CHECK (rev.14)',
                  labelStyle: Utils.isIpad ? headerL() : headerS(),
                  onTap: () {
                    context
                        .read<FormService>()
                        .newForm(context, FormService.initLineTrain());
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.add, color: kPrimaryDarker),
                  label: 'STANDARD LOFT (rev.04)',
                  labelStyle: Utils.isIpad ? headerL() : headerS(),
                  onTap: () {
                    context
                        .read<FormService>()
                        .newForm(context, FormService.initStdloft());
                  },
                ),
                // SpeedDialChild(
                //   child: Icon(Icons.add, color: kPrimaryDarker),
                //   label: 'PILOT PROFICIENCY CHECK / SKILL TEST (rev.04)',
                //   labelStyle: _header(),
                //   onTap: () {
                //     context
                //         .read<FormService>()
                //         .newForm(context, FormService.initPpc());
                //   },
                // ),
                // if (context.read<FormService>().rt6Valid())
                //   SpeedDialChild(
                //     child: Icon(Icons.add, color: kPrimaryDarker),
                //     label: 'RECURRENT TRAINING RT6 (rev.00)',
                //     labelStyle: _header(),
                //     onTap: () {
                //       context
                //           .read<FormService>()
                //           .newForm(context, FormService.initRt6());
                //     },
                //   ),
                // if (context.read<FormService>().rt5Valid())
                //   SpeedDialChild(
                //     child: Icon(Icons.add, color: kPrimaryDarker),
                //     label: 'RECURRENT TRAINING RT5 (rev.00)',
                //     labelStyle: _header(),
                //     onTap: () {
                //       context
                //           .read<FormService>()
                //           .newForm(context, FormService.initRt5());
                //     },
                //   ),
              ],
            ),
    );
  }

  AlertDialog _logOutWithConfirm() {
    return AlertDialog(
      // title: Text(widget.form.fields[index].label, style: label()),
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        width: 400,
        padding: EdgeInsets.symmetric(vertical: 20),
        // height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirm Logout?',
                style: TextStyle(
                  color: kPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    await Authen.logOut();
                    Navigator.of(context).pushReplacement(PageRouteBuilder(
                        settings: RouteSettings(name: kMainPageName),
                        pageBuilder: (_, __, ___) => Login()));
                  },
                  icon: Icon(Icons.check, size: 30, color: kPrimary),
                ),
                IconButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.clear, size: 30, color: kPenColor),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }
}
