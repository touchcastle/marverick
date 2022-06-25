import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:marverick/services/form_service.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/ui/views/log_in.dart';
import 'package:marverick/ui/widgets/snackbar.dart';
import 'package:marverick/utils/constants.dart';

class MainMenu extends StatefulWidget {
  static const id = kMainMenuId; //for route.
  int selectedIndex = 0;
  MainMenu({this.selectedIndex = 0});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late StreamSubscription<ConnectivityResult> subscription;
  ConnectivityResult? lastState;

  void _screenInit() async {
    ConnectivityResult connecticity = await Connectivity().checkConnectivity();
    print('>> $connecticity');
    subscription = await Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none &&
          (await Connectivity().checkConnectivity() ==
              ConnectivityResult.none)) {
        Snackbar.show(context,
            text:
                'NO INTERNET CONNECTION: You can create or edit form while offline.',
            type: Type.info,
            isFixed: true,
            duration: 10);
      } else {}
    });
  }

  @override
  void initState() {
    _screenInit();
    super.initState();
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

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<FormService>().countPending();
    String _pendingLabel = context.watch<FormService>().pendingCount > 0
        ? 'Pending (${context.watch<FormService>().pendingCount.toString()})'
        : 'Pending';
    String _draftLabel = context.watch<FormService>().draftCount > 0
        ? 'Draft (${context.watch<FormService>().draftCount.toString()})'
        : 'Draft';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimary,
        actions: [
          Authen.user == null
              ? TextButton(
                  child: const Text(
                    'Log In',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.of(context).push(PageRouteBuilder(
                        settings: RouteSettings(name: kMainPageName),
                        pageBuilder: (_, __, ___) => Login(fromInside: true)));
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
        ],
        // title: const Text('Choose PDF to create'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: IndexedStack(
              index: widget.selectedIndex, children: widgetOptions),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_done),
            label: 'Submitted',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload),
            label: _pendingLabel,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mode_edit),
            label: _draftLabel,
          ),
        ],
        currentIndex: widget.selectedIndex,
        selectedItemColor: kSecondary,
        backgroundColor: kPrimary,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 3,
          child: Icon(Icons.add),
          backgroundColor: kPrimaryAccent,
          onPressed: () {
            context
                .read<FormService>()
                .newForm(context, FormService.initLineCheck());
          }),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
    });
  }
}
