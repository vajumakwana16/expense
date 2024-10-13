import 'package:avatar_glow/avatar_glow.dart';
import 'package:expense/providers/authentication_provider.dart';
import 'package:expense/providers/txn_provider.dart';
import 'package:expense/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/dashboard.dart';

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
