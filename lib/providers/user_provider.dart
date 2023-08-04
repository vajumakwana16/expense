import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../screen/varification.dart';
import '../utils/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/contextServise.dart';
import '../utils/utils.dart';
import '../utils/webservice.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  final auth.FirebaseAuth authUser = auth.FirebaseAuth.instance;
  BuildContext? context = NavigationService.navigatorKey.currentContext;

  //session expire and go to login
  sessionExpired(BuildContext context) {
    Webservice.pref!.clear();
    Navigator.of(context).pushReplacementNamed(Approutes.login);
  }

  //CheckPhoneExist
  Future checkPhoneExist(String userphone) async {
    final checkPhoneExist =
        "${Webservice.baseurl}?action=CheckPhoneExists&phone=$userphone&app_version=${Webservice.appversion}&app_token=${Webservice.apptoken}&device_type=a";
    final url = Uri.parse(checkPhoneExist);
    bool isExist = false;
    try {
      final response = await http.post(url);
      print(response.body.toString());

      final responseData = json.decode(response.body);
      if (responseData['data']['is_exists'] == 1) {
        isExist = true;
      } else {
        isExist = false;
      }
      return isExist;
    } catch (error) {
      print(error.toString());
      return error.toString();
    }
  }

  //firebase verification
  Future verifyPhoneWithFirebase(BuildContext context, String cntCode,
      String name, String email, String uphone, int mode) async {
    if (kDebugMode) {
      print("verify : " + cntCode + name + email + uphone + mode.toString());
    }

    try {
      authUser.verifyPhoneNumber(
          //phoneNumber: '+91' + _initValues['phone'].toString(),
          phoneNumber: '${Webservice.cntCode}$uphone',
          verificationCompleted: (phoneAuthCredential) async {
            // ShowErrorDialog(phoneAuthCredential.toString());
          },
          verificationFailed: (verificationFailed) async {
            Utils.showErrorDialog(context, verificationFailed.toString());
          },
          codeSent: (verificationId, resendToken) async {
            Utils.buildshowTopSnackBar(
                context, Icons.code, 'Code Sent', 'success');
            if (mode == 0) {
              Future.delayed(Duration.zero, () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Varification(),
                    settings: RouteSettings(arguments: [
                      'Register',
                      resendToken,
                      verificationId,
                      uphone,
                      name,
                      email
                    ])));
              });
            } else {
              Future.delayed(Duration.zero, () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Varification(),
                    settings: RouteSettings(arguments: [
                      'Login',
                      resendToken,
                      verificationId,
                      uphone,
                      name,
                      email
                    ])));
              });
            }
          },
          codeAutoRetrievalTimeout: (verificationId) async {
            //ShowErrorDialog('Time Out');
          });
    } catch (e) {
      Webservice.printMag(e.toString());
    }
  }

  //register
  Future register(
      context, String cntCode, String phone, String name, String email) async {
    String msg = 'Somthing went wrong';

    try {
      final udid = await FirebaseMessaging.instance.getToken();
      final loginurl =
          Webservice.builRegisterUrl(udid!, cntCode, phone, name, email);

      final response = await http.post(loginurl);
      // Webservice.printMag(response.body.toString());
      final responseData = json.decode(response.body);

      int status = responseData['status'];
      msg = responseData['msg'].toString();

      if (status == 0) {
        return msg;
      }
      if (status == 1) {
        final profileimage =
            responseData['data']['profile']['profile_image'] == ''
                ? '0'
                : responseData['profile_img_url'].toString() +
                    // : Webservice.baseurl +
                    responseData['data']['profile']['profile_image'].toString();

        final user = User(
            id: responseData['data']['profile']['uid'].toString(),
            name: responseData['data']['profile']['name'].toString(),
            email: responseData['data']['profile']['email'].toString(),
            phone: responseData['data']['profile']['phone'].toString(),
            cntCode: responseData['data']['profile']['cnt_code'].toString(),
            balance: responseData['data']['profile']['total_balance'],
            udid: udid.toString(),
            logintoken:
                responseData['data']['profile']['login_token'].toString(),
            // isNotify: responseData['data']['profile']['is_notify'].toString(),
            profileimage: profileimage);
        await Webservice.pref!.clear();
        Webservice.setUser(user);
        Webservice.initUser();
        return true;
      }
      if (status == 2) {
        Utils.buildSnackbar(context!, msg);
        sessionExpired(context);
        return msg;
      }
      if (status == 3) {
        Utils.buildSnackbar(context!, msg);
        return msg;
      }
    } catch (e) {
      Webservice.printMag(e.toString());
      return e.toString();
    }
  }

  //login
  Future login(context, String phone) async {
    String? msg = 'Somthing went wrong';

    try {
      final udid = await FirebaseMessaging.instance.getToken();
      final loginurl =
          Webservice.builLoginUrl(udid!, Webservice.cntCode, phone);
      final response = await http.post(loginurl);

      final responseData = json.decode(response.body);
      // Webservice.printMag(responseData);
      int status = responseData['status'];
      msg = responseData['msg'].toString();

      if (status == 0) {
        return msg;
      }
      if (status == 1) {
        final profileimage =
            responseData['data']['profile']['profile_image'] == ''
                ? '0'
                : responseData['profile_img_url'].toString() +
                    // : Webservice.baseurl +
                    responseData['data']['profile']['profile_image'].toString();

        final user = User(
            id: responseData['data']['profile']['uid'].toString(),
            name: responseData['data']['profile']['name'].toString(),
            email: responseData['data']['profile']['email'].toString(),
            phone: responseData['data']['profile']['phone'].toString(),
            cntCode: responseData['data']['profile']['cnt_code'].toString(),
            balance:
                responseData['data']['profile']['total_balance'].toString(),
            logintoken:
                responseData['data']['profile']['login_token'].toString(),
            // isNotify: responseData['data']['profile']['is_notify'].toString(),
            profileimage: profileimage);
        await Webservice.pref!.clear();
        await Webservice.setUser(user);
        Webservice.initUser();
        return true;
      }
      if (status == 2) {
        Utils.buildSnackbar(context!, msg.toString());
        sessionExpired(context);
      }
      if (status == 3) {
        Utils.buildSnackbar(context!, msg.toString());
      }
    } catch (e) {
      Webservice.printMag("init user ");
      Webservice.printMag(e.toString());
      Utils.buildSnackbar(context, e.toString());
      return e.toString();
      //Utils.buildSnackbar(context!, e.toString());
    }
  }

  //update profile
  Future updateProfile(context, name, email) async {
    try {
      final updateurl = Webservice.buildUpdateurl('UpdateProfile', name, email);
      final response = await http.post(updateurl);
      if (response.statusCode == 200) {
        // print(response.body);
        final responseData = json.decode(response.body);
        final status = responseData['status'];
        final msg = responseData['msg'];
        if (status == 0) {
          Utils.buildshowTopSnackBar(context!, Icons.close, msg, 'error');
        } else if (status == 1) {
          final oldUser = Webservice.getUser();
          final user = oldUser.copy(
              name: responseData['data']['profile']['name'].toString(),
              email: responseData['data']['profile']['email'].toString());
          await Webservice.setUser(user);
          await Webservice.initUser();
          Utils.buildshowTopSnackBar(context!, Icons.done, msg, 'success');
        } else if (status == 2) {
          Utils.buildshowTopSnackBar(context!, Icons.close, msg, 'error');
          sessionExpired(context);
        }
      }
    } catch (e) {
      Utils.showErrorDialog(context!, e.toString());
    }
  }

  //update profile
  Future updateProfileImage(context, File file) async {
    // print(file.path);
    try {
      final url = Uri.parse(
          "${Webservice.baseurl}?action=UpdateProfileImage&uid=${Webservice.uid}&login_token=${Webservice.logintoken}&app_token=${Webservice.apptoken}&app_version=${Webservice.appversion}&device_type=${Webservice.devicetype}");

      var request = http.MultipartRequest("POST", url);
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();
      // print(stream.toString() + length.toString());
      var multipartFile = http.MultipartFile('profile_image', stream, length,
          filename: 'abc.jpeg');

      // add file to multipart
      request.files.add(multipartFile);

      final response = await request.send();
      // if (response.statusCode == 200) {
      var getingresponse = await response.stream.toBytes();
      final responseData = json.decode(String.fromCharCodes(getingresponse));
      print("responseData.toString()");
      print(responseData.toString());
      final status = responseData['status'];
      final msg = responseData['msg'];
      if (status == 0) {
        Utils.buildshowTopSnackBar(context, Icons.info, msg, 'error');
      } else if (status == 1) {
        final profileimage =
            responseData['data']['profile']['profile_image'] == ''
                ? responseData['profile_img_url'].toString() + "placeholder.jpg"
                : responseData['profile_img_url'].toString() +
                    responseData['data']['profile']['profile_image'].toString();
        final oldUser = Webservice.getUser();
        final user = oldUser.copy(
            id: responseData['data']['profile']['uid'].toString(),
            name: responseData['data']['profile']['name'].toString(),
            email: responseData['data']['profile']['email'].toString(),
            phone: responseData['data']['profile']['phone'].toString(),
            cntCode: responseData['data']['profile']['cnt_code'].toString(),
            logintoken:
                responseData['data']['profile']['login_token'].toString(),
            // isNotify: responseData['data']['profile']['is_notify'].toString(),
            profileimage: profileimage);
        await Webservice.setUser(user);
        await Webservice.initUser();
        Utils.buildshowTopSnackBar(context, Icons.done, msg, 'success');
      } else if (status == 2) {
        Utils.buildshowTopSnackBar(context, Icons.info, msg, 'error');
        // sessionExpired(context);
      }
    } catch (e) {
      Utils.buildshowTopSnackBar(context, Icons.info, e.toString(), 'error');
    }
  }
}
