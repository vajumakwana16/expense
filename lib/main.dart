import 'package:expense/providers/txn_provider.dart';
import 'package:expense/screen/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../providers/theme_previder.dart';
import '../providers/user_provider.dart';
import '../screen/fixed_transactions.dart';
import '../screen/home.dart';
import '../screen/on_boarding.dart';
import '../utils/webservice.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/contextServise.dart';
import 'providers/authentication_provider.dart';
import 'screen/profile.dart';
import 'screen/settings.dart';
import 'utils/utils.dart';
import 'widgets/new_transaction.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

bool authEnabled = false;
late bool is_first;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Webservice.init();
  await Webservice.prefgetBool('usefingerprint')
      .then((value) => {authEnabled = value});
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    // appleProvider: AppleProvider.appAttest,
  );

  is_first = await Webservice.prefgetBool('is_first') == null ? false : true;
  print("object");
  print(Webservice.pref?.getBool('is_first'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => TxnProvider()),
          ChangeNotifierProvider(create: (ctx) => UserProvider()),
          ChangeNotifierProvider(create: (ctx) => AuthenticationProvider()),
          ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
        ],
        child: Consumer<ThemeProvider>(
            builder: (ctx, themeProvider, _) => MaterialApp(
                  title: 'EXPENSE',
                  theme: MyTheme.dynamicTheme(context,
                      themeProvider.currenttheme, themeProvider.isDarkMode),
                  home: is_first == false
                      ? OnBoarding()
                      : Consumer<AuthenticationProvider>(
                          builder: (ctx, authProvider, _) => authEnabled
                              ? const PhoneAuthScreen()
                              : (Webservice.name == ''
                                  ? const ScreenAuthentication()
                                  : Consumer<TxnProvider>(
                                      builder: (ctx, txnProvider, _) => Main(
                                          bottomNavIndex: 0,
                                          txnProvider: txnProvider)))),
                  debugShowCheckedModeBanner: false,
                  /* routes: {
                    Approutes.main: (context) => Main(
                        bottomNavIndex: 0,
                        txnProvider:
                            Provider.of<TxnProvider>(context, listen: true)),
                    Approutes.login: (context) => const ScreenAuthentication(),
                    Approutes.verification: (context) => const Varification(),
                    Approutes.phoneauth: (context) => const PhoneAuthScreen(),
                    Approutes.home: (context) => const Home(),
                    Approutes.detail: (context) => DetailPage(
                        txn: Transaction(
                            id: "1",
                            title: "title",
                            amount: 120,
                            note: "test note",
                            date: DateTime.now(),
                            type: "expense")),
                    Approutes.profile: (context) => const Profile(),
                    Approutes.settings: (context) => const Settings(),
                  },*/
                )));
  }
}

//authentication
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  int isFirst = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    auth() {
      authProvider.authenticate().then((value) {
        if (authProvider.authorized == 'Not Authorized') {
          Utils.buildshowTopSnackBar(
              context,
              Icons.fingerprint,
              'Failed to authenticate\n Tap fingerprint icon and try again.',
              'info');
        }
      });
    }

    if (isFirst == 0) {
      auth();
      setState(() {
        isFirst = 1;
      });
    }

    onClick() {
      auth();
    }

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      // key: NavigationService.navigatorKey,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      body: authProvider.authorized != 'Authorized'
          ? Stack(fit: StackFit.expand, children: [
              AvatarGlow(
                  endRadius: 80,
                  child: Utils.buildSizedIcon(
                      onClick, Icons.fingerprint, Colors.white, 100)),
              Align(
                  heightFactor: 100,
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: width * 0.05, horizontal: width * 0.03),
                    child: Utils.buildText(
                        'Please authenticate to access expense'),
                  )),
            ])
          : Consumer<TxnProvider>(
              builder: (ctx, txnProvider, _) =>
                  Main(bottomNavIndex: 0, txnProvider: txnProvider)),
    );
  }
}

//main home screen with navigation
// ignore: must_be_immutable
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
        if (Webservice.balance == '0') {
          Utils.buildBalanceDialog(context, onAddBalance, width, height, '', '',
              'First you have to add Balance', 'Add');
        } else {
          final from = _bottomNavIndex == 0 ? "home" : "fixed";
          showModalBottomSheet(
            enableDrag: true,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            context: ctx,
            builder: (context) {
              return FractionallySizedBox(
                  child: GestureDetector(
                      onTap: (() {}),
                      child: NewTransaction(
                          addT: txnProvider.addNewTransaction, from: from),
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
                heroTag: null,
                elevation: 0,
                splashColor: Colors.lightBlue,
                child: const Icon(
                  Icons.add_circle,
                  color: Colors.white,
                ),
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
          child: screens[_bottomNavIndex]),
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
