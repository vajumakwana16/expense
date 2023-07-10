import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/webservice.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class AuthenticationProvider with ChangeNotifier {
  final auth = Webservice.auth;
  _SupportState supportState = _SupportState.unknown;
  bool? canCheckBiometrics;
  List<BiometricType>? availableBiometrics;
  String authorized = 'Not Authorized';
  bool isAuthenticating = false;
  bool authenticated = false;

  checkSupported() {
    auth!.isDeviceSupported().then((bool isSupported) => supportState =
        isSupported ? _SupportState.supported : _SupportState.unsupported);
    notifyListeners();
  }

  Future<void> checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth!.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
    }

    canCheckBiometrics = canCheckBiometrics;
    notifyListeners();
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth!.getAvailableBiometrics();
    } catch (e) {
      availableBiometrics = <BiometricType>[];
      // print(e);
    }
    availableBiometrics = availableBiometrics;
    notifyListeners();
  }

  Future<void> authenticate() async {
    try {
      authenticated = await Webservice.auth!.authenticate(
        // localizedReason: 'Let OS determine authentication method',
        localizedReason: 'Fingerprint Authentication is required',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      // print(authenticated);
    } on PlatformException catch (e) {
      print(e);
      authenticated = false;
      return;
    }

    authorized = authenticated ? 'Authorized' : 'Not Authorized';

    notifyListeners();
  }

  Future<void> authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      isAuthenticating = true;
      authorized = 'Authenticating';
      authenticated = await auth!.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      isAuthenticating = false;
      authorized = 'Authenticating';
    } on PlatformException catch (e) {
      // print(e);

      isAuthenticating = false;
      authorized = 'Error - ${e.message}';
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';

    authorized = message;
    notifyListeners();
  }

  Future<void> cancelAuthentication() async {
    await auth!.stopAuthentication();
    isAuthenticating = false;
    notifyListeners();
  }
}
