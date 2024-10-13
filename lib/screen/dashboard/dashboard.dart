import 'package:expense/providers/theme_previder.dart';
import 'package:expense/screen/fixed_transactions.dart';
import 'package:expense/screen/home.dart';
import 'package:expense/screen/profile.dart';
import 'package:expense/utils/contextServise.dart';
import 'package:expense/widgets/new_transaction.dart';
import 'package:flutter/material.dart';
import 'package:expense/providers/txn_provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../utils/utils.dart';
import '../../utils/webservice.dart';
import '../settings.dart';

class Main extends StatefulWidget {
  final int bottomNavIndex;
  TxnProvider txnProvider;
  Main({Key? key, required this.bottomNavIndex, required this.txnProvider})
      : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with TickerProviderStateMixin {
  //  final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 0; //default index of a first screen

  late AnimationController _fabAnimationController;
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation fabCurve;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

  // void listenNotification() =>
  //     NotificationHelper.onNotifications.stream.listen(onClickNotification);
  // void onClickNotification(String? payload) => setState(() {
  //       _bottomNavIndex = 2;
  //     });

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.bottomNavIndex;

    final systemTheme = SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: Colors.transparent, //HexColor('#373A36')
      systemNavigationBarIconBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(systemTheme);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _borderRadiusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fabCurve = CurvedAnimation(
      parent: _fabAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.bounceInOut),
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    fabAnimation = Tween<double>(begin: 0, end: 1).animate(fabCurve);
    borderRadiusAnimation =
        Tween<double>(begin: 0, end: 1).animate(borderRadiusCurve);

    _hideBottomBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      const Duration(seconds: 1),
      () => _fabAnimationController.forward(),
    );
    Future.delayed(
      const Duration(milliseconds: 800),
      () => _borderRadiusAnimationController.forward(),
    );
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (_bottomNavIndex == 0) {
      if (notification is UserScrollNotification &&
          notification.metrics.axis == Axis.vertical) {
        switch (notification.direction) {
          case ScrollDirection.forward:
            _hideBottomBarAnimationController.reverse();
            _fabAnimationController.forward(from: 0);
            break;
          case ScrollDirection.reverse:
            _hideBottomBarAnimationController.forward();
            _fabAnimationController.reverse(from: 1);
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }

  final screens = [
    const Home(),
    const Fixed(),
    const Profile(),
    const Settings()
  ];
  final screenName = ['Home', 'Fixed', 'Profile', 'Settings'];
  final iconList = <IconData>[
    Icons.home,
    Icons.auto_graph,
    Icons.person,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    final txnProvider = widget.txnProvider;
    final themeProvider = Provider.of<ThemeProvider>(context);
    //checking is landScap or not
    final isLandScape = mediaQuery.orientation == Orientation.landscape;

    onAddBalance() async {
      await txnProvider.addBalance(context);
      Navigator.of(context).pop();
    }

    void _startNewAddTransaction(BuildContext ctx) {
      try {
        if (Webservice.balance == 0.0) {
          Utils.buildBalanceDialog(context, onAddBalance, width, height, '', '',
              'First you have to add Budget', 'Add');
        } else {
          final from = _bottomNavIndex == 0 ? "home" : "fixed";
          showModalBottomSheet(
            enableDrag: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: ctx,
            builder: (context) {
              return FractionallySizedBox(
                  heightFactor: 0.9,
                  child: GestureDetector(
                      onTap: (() {}),
                      child: NewTransaction(
                          addT: () => txnProvider.addNewTransaction,
                          from: from),
                      behavior: HitTestBehavior.translucent));
            },
          );
        }
      } catch (e) {
        Utils.showErrorDialog(context, e.toString());
      }
    }

    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;

    // FloatingAction Button
    final floatingActionbutton = isLandScape
        ? Container()
        : Padding(
            padding: const EdgeInsets.only(bottom: 7.0),
            child: Container(
              decoration: Utils.buildBoxDecoration(context, 50, Colors.black),
              child: FloatingActionButton(
                materialTapTargetSize: MaterialTapTargetSize.padded,
                elevation: 0,
                splashColor: Colors.lightBlue,
                child: const Icon(Icons.add_circle, color: Colors.white),
                onPressed: () {
                  _startNewAddTransaction(context);
                },
              ),
            ),
          );

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? Theme.of(context).primaryColor
          : Webservice.bgColor,
      key: NavigationService.navigatorKey,
      body: NotificationListener<ScrollNotification>(
          onNotification: onScrollNotification,
          child: IndexedStack(index: _bottomNavIndex, children: screens)),
      floatingActionButton: showFab ? floatingActionbutton : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive
              ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
              : Theme.of(context).disabledColor;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 23,
                color: color,
              ),
              if (_bottomNavIndex == index)
                Text(screenName[index],
                    style: const TextStyle(color: Colors.white))
            ],
          );
        },
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        activeIndex: _bottomNavIndex,
        splashRadius: 10,
        blurEffect: true,
        elevation: 6,
        splashColor: Colors.white,
        notchAndCornersAnimation: borderRadiusAnimation,
        // splashSpeedInMilliseconds: 600,
        notchSmoothness: NotchSmoothness.smoothEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 30,
        rightCornerRadius: 30,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        hideAnimationController: _hideBottomBarAnimationController,
        shadow: const BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 15,
          spreadRadius: 0.8,
          color: Colors.black26,
        ),
      ),
    );
  }
}
