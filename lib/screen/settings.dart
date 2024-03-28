import 'dart:io';

import '../providers/theme_previder.dart';
import '../utils/contextServise.dart';
import '../utils/webservice.dart';
// import '../utils/notification_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../utils/app_routes.dart';
import '../utils/utils.dart';
import '../providers/txn_provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

// enum Themesname { cyan, purple, red, green }

class _SettingsState extends State<Settings> {
  bool fingerPrentSwitch = false;
  bool darkModeSwitch = false;
  bool notificationSwitch = false;

  @override
  void initState() {
    Webservice.prefgetBool('usefingerprint').then((value) => setState(() {
          fingerPrentSwitch = value;
        }));
    Webservice.prefgetBool('darkmode').then((value) => setState(() {
          // print(value);
          darkModeSwitch = value;
        }));
    Webservice.prefgetBool('notification').then((value) => setState(() {
          // print(value);
          notificationSwitch = value;
        }));

    super.initState();
  }

  //logout
  void logout() {
    Webservice.pref!.remove('user');
    Navigator.of(NavigationService.navigatorKey.currentContext!)
        .pushReplacementNamed(Approutes.login);
  }

  //about
  void about() {}
  //use fungerprint
  bool isBiometricAvailable = false;
  setFingerprint(value) {
    setState(() {
      fingerPrentSwitch = value;
      Webservice.pref!.setBool('usefingerprint', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    final txnProvider = Provider.of<TxnProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    //set theme
    setTheme(Themesname color) {
      Webservice.pref!.setString('theme', color.toString());
      themeProvider.changeTheme(color);
    }

    //theme item
    Widget buildThemeItem(Themesname color, Color themeColor) {
      String? ctheme = Webservice.pref!.getString('theme');
      return GestureDetector(
        onTap: () => setTheme(color),
        // onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => Settheme())),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ctheme == color.toString()
                  ? Colors.white
                  : Colors.transparent),
          child: Container(
            height: 50,
            width: 50,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: themeColor),
          ),
        ),
      );
    }

    //on click add balance
    onAddBalance() async {
      await txnProvider.addBalance(context);
      Navigator.of(context).pop();
    }

    //show balance dialog
    showAddBalance() {
      Utils.buildBalanceDialog(
          context, onAddBalance, width, height, '', 'Add Balance', '', 'Add');
    }

    final LocalAuthentication auth = LocalAuthentication();
    auth.isDeviceSupported().then((bool isSupported) {
      isSupported
          ? setState(() {
              isBiometricAvailable = true;
            })
          : setState(() {
              isBiometricAvailable = false;
            });
    });

    //androidAppbar
    final PreferredSizeWidget appbar = Utils.buildAppbar(context, 'Settings');

    //body
    final pageBody = Builder(
        builder: (context) => ListView(
              children: [
                Utils.sizedBox(height * 0.1, 0.2),

                //add balance
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: Utils.buildBoxDecoration(
                        context, 10, Webservice.bgColor!),
                    child: Utils.buildListTile(context, Icons.monetization_on,
                        'Add Balance', showAddBalance)),

                //use fingerprint
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: Utils.buildBoxDecoration(
                        context, 10, Webservice.bgColor!),
                    child: Utils.buildAuthListTile(
                        context,
                        isBiometricAvailable,
                        Icons.fingerprint,
                        fingerPrentSwitch,
                        'Use Fingerprint',
                        setFingerprint,
                        SwitchType.cupertino)),

                //dark mode
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: Utils.buildBoxDecoration(
                        context, 10, Webservice.bgColor!),
                    child: Utils.buildListTileSwitch(
                        context,
                        Icons.brightness_6,
                        darkModeSwitch,
                        'Dark mode', (value) {
                      setState(() {
                        darkModeSwitch = value;
                        Webservice.pref!.setBool('darkmode', value);
                        themeProvider.toggleTheme(darkModeSwitch);
                      });
                    }, SwitchType.cupertino)),

                //monthly notification
                Visibility(
                  visible: false,
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: Utils.buildBoxDecoration(
                          context, 10, Webservice.bgColor!),
                      child: Utils.buildListTileSwitch(
                          context,
                          notificationSwitch
                              ? Icons.notifications_active
                              : Icons.notification_important_sharp,
                          notificationSwitch,
                          'Notifications', (value) {
                        setState(() async {
                          notificationSwitch = value;
                          Webservice.pref!.setBool('notification', value);
                          // NotificationHelper.showNotification();
                          if (notificationSwitch) {
                            try {
                              // await NotificationHelper.showSheduledNotification(
                              //     id: 0,
                              //     title: "Your Monthly Transactions",
                              //     body: "Hey! Remember your Pending Transactions",
                              //     scheduledTime: DateTime.now(),
                              //     payload: "fixed");
                            } catch (e) {
                              Utils.showErrorDialog(context, e.toString());
                            }
                          } else {
                            try {
                              // await NotificationHelper.cancelNotification();
                            } catch (e) {
                              Utils.showErrorDialog(context, e.toString());
                            }
                          }
                        });
                      }, SwitchType.cupertino)),
                ),

                //about
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: Utils.buildBoxDecoration(
                        context, 10, Webservice.bgColor!),
                    child: Utils.buildListTile(
                        context, Icons.info, 'About', about)),

                //logout
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: Utils.buildBoxDecoration(
                        context, 10, Webservice.bgColor!),
                    child: Utils.buildListTile(
                        context, Icons.logout, 'Logout', logout)),

                //chane theme
                Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: Utils.buildBoxDecoration(
                        context, 10, Webservice.bgColor!),
                    child: Column(
                      children: [
                        const Text('Theme'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildThemeItem(Themesname.cyan, Colors.cyan),
                            buildThemeItem(Themesname.purple, Colors.purple),
                            buildThemeItem(Themesname.red, Colors.red),
                            buildThemeItem(Themesname.green, Colors.green),
                          ],
                        ),
                      ],
                    )),
              ],
            ));

    return Platform.isAndroid
        ? Scaffold(
            backgroundColor: themeProvider.isDarkMode
                ? Theme.of(context).primaryColor
                : Webservice.bgColor,
            appBar: appbar,
            body: pageBody,
          )
        : CupertinoPageScaffold(child: pageBody);
  }
}
