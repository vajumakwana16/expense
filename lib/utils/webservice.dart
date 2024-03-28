import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class Webservice {
  static const String baseurl =
      "https://barbellate-caution.000webhostapp.com/expense/api/"; //laptop
  // static const String baseurl = "http://192.168.43.237/expense/api/"; //vaju
  // static const String baseurl = "http://vajumakwana.epizy.com/expense/api/";

  static const String apptoken = "123456";
  static const String appversion = "1.0";
  static const String devicetype = "a";
  static const String apikey = "AIzaSyCKP4esBA80tJTkGIEYXdqwzimvpBAFf70";

  static bool developerMode = true;
  static String balance = '';
  static String uid = "";
  static String name = "";
  static String email = "";
  static String phone = "";
  static String cntCode = "+91";
  static String udid = "";
  static String logintoken = "";
  static String profileimage = "";
  static String isNotify = "";
  static String isFirst = "";
  // static var placeholder =Webservice.baseurl + 'assets/uploads/profile_images/placeholder.jpg';
  static var placeholder =
      'https://media.istockphoto.com/vectors/default-avatar-photo-placeholder-icon-grey-profile-picture-business-vector-id1327592506?k=20&m=1327592506&s=612x612&w=0&h=hgMOPfz7H-CYP_CQ0wbv3IwRkbQna32xWUPoXtMyg5M=';

  static printMag(String msg) {
    print(msg);
  }

  static Uri builRegisterUrl(String rudid, String rcntCode, String authphone,
      String authname, String authemail) {
    return Uri.parse(
        "$baseurl?action=Register&udid=$rudid&phone=$authphone&cnt_code=$rcntCode&name=$authname&email=$authemail&app_token=$apptoken&app_version=$appversion&device_type=$devicetype");
  }

  static Uri builLoginUrl(String ludid, String lcntCode, String authphone) {
    return Uri.parse(
        "$baseurl?action=Login&udid=$ludid&cnt_code=$lcntCode&phone=$authphone&app_token=$apptoken&app_version=$appversion&device_type=$devicetype");
  }

  static Uri buildUpdateurl(
      String action, String updatename, String updateemail) {
    return Uri.parse(
        "$baseurl?action=UpdateProfile&uid=${Webservice.uid}&name=$updatename&email=$updateemail&login_token=${Webservice.logintoken}&app_token=$apptoken&app_version=$appversion&device_type=$devicetype");
  }

  static Uri buildDeleteTransactionUrl(String from, String id, totalBalance) {
    return Uri.parse(
        "$baseurl?action=DeleteTransaction&tid=$id&total_balance=$totalBalance&uid=${Webservice.uid}&login_token=${Webservice.logintoken}&from=$from&app_token=$apptoken&app_version=$appversion&device_type=$devicetype");
  }

  static String? newBalance;
  static Uri buildAddBalance(String bal) {
    return Uri.parse(
        "$baseurl?action=AddBalance&balance=$bal&uid=${Webservice.uid}&login_token=${Webservice.logintoken}&app_token=$apptoken&app_version=$appversion&device_type=$devicetype");
  }

  static Uri buildUrl(String action) {
    return Uri.parse(
        "$baseurl?action=$action&uid=${Webservice.uid}&login_token=${Webservice.logintoken}&app_token=$apptoken&app_version=$appversion&device_type=$devicetype");
  }

  static Uri buildDoneUrl(String txn_id) {
    return Uri.parse(
        "$baseurl?action=CompletedTransaction&txn_id=$txn_id&uid=${Webservice.uid}&login_token=${Webservice.logintoken}&app_token=$apptoken&app_version=$appversion&device_type=$devicetype");
  }

  static LocalAuthentication? auth;
  static SharedPreferences? pref;

  static init() async {
    auth = LocalAuthentication();
    pref = await SharedPreferences.getInstance();
    initUser();
  }

  static Future prefgetBool(key) async {
    final value = pref!.getBool(key);
    return value ?? false;
  }

  static Future setUser(User user) async {
    final json = jsonEncode(user.toJson());
    await pref!.setString('user', json);
  }

  static User getUser() {
    final json = pref!.getString('user');
    if (json == null) {
      throw 'User not found';
    }
    return User.fromJson(jsonDecode(json));
  }

  static bool isUserSeted() {
    if (pref!.containsKey('user')) {
      return true;
    }
    return false;
  }

  static initUser() {
    if (isUserSeted()) {
      uid = getUser().id;
      name = getUser().name;
      email = getUser().email;
      phone = getUser().phone;
      udid = getUser().udid;
      logintoken = getUser().logintoken;
      profileimage = getUser().profileimage;
      balance = getUser().balance.toString();
    }
  }

  static Color? bgColor = Colors.grey[300];

  static formateNumber(amount) {
    return NumberFormat.compactCurrency(
      decimalDigits: 0,
      symbol: '₹',
    ).format(amount);
  }
}
