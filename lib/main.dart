import 'package:expense/firebase_options.dart';
import 'package:expense/models/transaction.dart';
import 'package:expense/providers/txn_provider.dart';
import 'package:expense/screen/auth/auth.dart';
import 'package:expense/screen/detail_page.dart';
import 'package:expense/screen/varification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../providers/theme_previder.dart';
import '../providers/user_provider.dart';
import '../screen/home.dart';
import '../screen/on_boarding.dart';
import '../utils/webservice.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'providers/authentication_provider.dart';
import 'screen/auth/biometrics.dart';
import 'screen/dashboard/dashboard.dart';
import 'screen/profile.dart';
import 'screen/settings.dart';
import 'utils/app_routes.dart';

bool authEnabled = false;
late bool is_first;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Webservice.init();
  await Webservice.prefgetBool('usefingerprint')
      .then((value) => {authEnabled = value});
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug, //playIntegrity
  //   appleProvider: AppleProvider.appAttest,
  // );

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
                  title: 'E-XPENSE',
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
                  routes: {
                    Approutes.main: (context) => Consumer<TxnProvider>(
                        builder: (ctx, txnProvider, _) =>
                            Main(bottomNavIndex: 0, txnProvider: txnProvider)),
                    Approutes.home: (context) => const Home(),
                    Approutes.auth: (context) => const PhoneAuthScreen(),
                    Approutes.login: (context) => const ScreenAuthentication(),
                    Approutes.verification: (context) => const Varification(),
                    Approutes.profile: (context) => const Profile(),
                    Approutes.settings: (context) => const Settings(),
                    Approutes.detail: (context) =>
                        DetailPage(txn: Transaction()),
                  },
                )));
  }
}
