// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

import 'package:expense/utils/webservice.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_routes.dart';

enum DeviceType { isTablet, isMobile, isWeb }

class Utils {
  Utils._();

  //navigation
  goTOScreen(String screen) {}

  //screen background
  static screenBg(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 236, 230, 223),
              // const Color.fromRGBO(51, 51, 255, 1).withOpacity(0.2),
              Theme.of(context).primaryColor
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 1],
          ),
        ),
      );

  //device type (isMobile , isTab ,isWeb)
  static getDevice(BuildContext context) {
    if (MediaQuery.of(context).size.width < 800) {
      return DeviceType.isMobile;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return DeviceType.isTablet;
    } else if (MediaQuery.of(context).size.width >= 800 &&
        MediaQuery.of(context).size.width <= 1400) {
      return DeviceType.isWeb;
    }
  }

  static buildBoxDecoration(BuildContext context, double radius, Color color) {
    final isDarkkmode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
        // border: Border.all(width: 0.4, color: Colors.white),
        borderRadius: BorderRadius.circular(radius),
        color: isDarkkmode ? Colors.black54 : color,
        boxShadow: [
          BoxShadow(
            color: isDarkkmode ? Colors.white12 : Colors.white,
            offset: isDarkkmode ? const Offset(-1, -1) : const Offset(-5, -5),
            blurRadius: isDarkkmode ? 5 : 15,
            spreadRadius: isDarkkmode ? 0 : 1,
          ),
          BoxShadow(
            color: isDarkkmode ? Colors.white12 : Colors.grey.shade400,
            offset: isDarkkmode ? const Offset(1, 1) : const Offset(5, 5),
            blurRadius: isDarkkmode ? 5 : 15,
            spreadRadius: isDarkkmode ? 0 : 1,
          )
        ]);
  }

  static buildBoxDecorationTapd(
      BuildContext context, double radius, Color color) {
    final isDarkkmode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
        // border: Border.all(width: 0.4, color: Colors.white),
        borderRadius: BorderRadius.circular(radius),
        color: isDarkkmode ? Colors.black54 : color,
        boxShadow: [
          BoxShadow(
            color: isDarkkmode ? Colors.white12 : Colors.grey.shade400,
            offset: isDarkkmode ? const Offset(-1, -1) : const Offset(-5, -5),
            blurRadius: isDarkkmode ? 5 : 15,
            spreadRadius: isDarkkmode ? 0 : 1,
          ),
          BoxShadow(
            color: isDarkkmode ? Colors.white12 : Colors.white,
            offset: isDarkkmode ? const Offset(1, 1) : const Offset(5, 5),
            blurRadius: isDarkkmode ? 5 : 15,
            spreadRadius: isDarkkmode ? 0 : 1,
          )
        ]);
  }

  //session expire and go to login
  static sessionExpired(BuildContext context) {
    Webservice.pref!.remove('user');
    Navigator.of(context).pushReplacementNamed(Approutes.login);
  }

  static buildAppbar(BuildContext context, String title) => AppBar(
        elevation: 0,
        shadowColor: Colors.cyan,
        shape: const RoundedRectangleBorder(
            // borderRadius: BorderRadius.only(
            //     bottomLeft: Radius.circular(20),
            //     bottomRight: Radius.circular(20)),
            side: BorderSide.none),
        bottomOpacity: 0,
        centerTitle:
            !(title == 'Expense' || title.contains('Fixed')) ? true : false,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(2.0, 1.0),
                blurRadius: 6.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        actions: [
          if (title == 'Expense' || title.contains('Fixed'))
            Center(
                child: Text(
              "Balance :  ${Webservice.formateNumber(Webservice.balance)}",
              style: const TextStyle(color: Colors.white),
            ))
        ],
      );

  static buildAppbar2(BuildContext context, String title) {
    //checking is landScap or not
    //androidAppbar
    final PreferredSizeWidget appbar = AppBar(
      title: const Text(
        'E-XPENSES',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );

    return appbar;
  }

  static showProgressIndicator(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      color: Theme.of(context).secondaryHeaderColor,
    ));
  }

  static sizedBox(height, value) {
    return SizedBox(
      height: height * value,
    );
  }

  static buildIcon(IconData icon) {
    return Icon(icon, color: Colors.white);
  }

  static buildSizedIcon(onClick, IconData icon, Color color, double size) {
    return InkWell(
        borderRadius: BorderRadius.circular(50),
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.black45),
        onTap: onClick,
        child: Padding(
          padding: EdgeInsets.all(size * 0.02),
          child: Icon(
            icon,
            color: color,
            size: size,
            shadows: const [
              Shadow(
                color: Color(0xff5e5e5e),
                offset: Offset(0.3, 0.3),
                blurRadius: 20,
              )
            ],
          ),
        ));
  }

  static buildText(String text) {
    return Text(text,
        style: const TextStyle(fontSize: 16, color: Colors.white));
  }

  static buildTitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black));
  }

  static void showSuccessDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: const Text(
                'Success',
                style: TextStyle(color: Colors.green),
              ),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Okay'))
              ],
            ));
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: const Text(
                'Error Occured!',
                style: TextStyle(color: Colors.red),
              ),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Okay'))
              ],
            ));
  }

  static buildSnackbar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );

    if (message.contains("Session")) {
      // await Preference.logout().then((value) {
      //Navigator.of(context).pushReplacementNamed(Screen_Login.routeName);
      // });
    }
  }

  static buildshowTopSnackBar(
      BuildContext context, IconData icon, String msg, String type) {
    if (type == 'success') {
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          icon: Icon(icon, color: Colors.white, size: 30),
          iconRotationAngle: 0,
          iconPositionLeft: 10,
          message: msg.isEmpty ? 'Somthing Went Wrong!' : msg,
        ),
      );
    } else if (type == 'error') {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          icon: Icon(icon, color: Colors.white, size: 30),
          iconRotationAngle: 0,
          iconPositionLeft: 10,
          message: msg.isEmpty ? 'Somthing Went Wrong!' : msg,
        ),
      );
    } else {
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          icon: Icon(icon, color: Colors.white, size: 30),
          iconRotationAngle: 0,
          iconPositionLeft: 10,
          message: msg.isEmpty ? 'Somthing Went Wrong!' : msg,
        ),
      );
    }
  }

  static buildEditText(BuildContext context, bool isEnabled, String initValue,
      String hint, String lbl, onChange, String validateMsg) {
    final isDarkkmode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      keyboardType: hint == 'Enter Budget'
          ? TextInputType.number
          : TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enableSuggestions: true,
      textInputAction: TextInputAction.done,
      enabled: isEnabled ? true : false,
      initialValue: initValue,
      // textAlign: TextAlign.center,
      decoration: InputDecoration(
          hintText: hint,
          labelText: lbl,
          border: InputBorder.none,
          labelStyle: TextStyle(
              color: isDarkkmode
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).primaryColor)),
      onChanged: onChange,
      validator: (value) {
        if (value!.isEmpty) {
          return validateMsg;
        }
        return null;
      },
    );
  }

  static buildEditTextWithController(
    int maxLength,
    TextInputType inputType,
    IconData icon,
    bool isEnabled,
    bool isobscureText,
    VoidCallback onChange,
    TextEditingController controller,
    String hint,
    String lbl,
    String validateMsg,
  ) {
    return TextFormField(
      maxLength: maxLength,
      keyboardType: inputType,
      enabled: isEnabled ? true : false,
      obscureText: isobscureText ? true : false,
      controller: controller,
      decoration: InputDecoration(
          hintText: hint,
          labelText: lbl,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon)),
      onChanged: (value) => onChange,
      validator: (value) {
        if (value!.isEmpty) {
          return validateMsg;
        }
        if (hint == "Enter Phone") {
          if (value.length < 10) {
            return "Enter valid phone number";
          }
        }
        if (hint == "Enter Password") {
          if (validateMsg.toLowerCase().contains('password') &&
              validateMsg.characters.length < 6) {
            return 'Password must be 6 Character long';
          }
        }
        return null;
      },
    );
  }

  //image
  static buildProfileImage(String profileimage, double height) {
    return SizedBox(
      height: height,
      child: Center(
        child: Hero(
          tag: "profile_image",
          child: CircleAvatar(
              radius: 100.0, backgroundImage: NetworkImage(profileimage)),
        ),
      ),
    );
  }

  static buildSmallProfileImage(String profileimage) {
    return SizedBox(
      height: 80,
      child: Center(
        child: Hero(
          tag: "profile_image",
          child: CircleAvatar(
            radius: 40.0,
            backgroundImage: NetworkImage(profileimage),
          ),
        ),
      ),
    );
  }

  static buildProfileImagewithShadow(
      BuildContext context, String profileImage, height, width, onImageTap) {
    return Container(
      width: width * 0.30,
      height: height * 0.30,
      color: Colors.transparent,
      alignment: Alignment.center,
      transformAlignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(2),
        width: height * 0.22,
        height: height * 0.22,
        decoration: buildBoxDecoration(
            context, 80, Theme.of(context).secondaryHeaderColor),
        child: Center(
          child: Hero(
            tag: "profile_image",
            child: InkWell(
              onTap: onImageTap,
              child:
                  // CachedNetworkImage(imageBuilder: (context, imageProvider) =>
                  Container(
                alignment: Alignment.center,
                height: height * 0.2,
                width: height * 0.2,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(profileImage), fit: BoxFit.cover)),
              ),
              /* imageUrl: profileImage,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) {
                  print("error : $error");
                  return const Icon(Icons.error);
                },*/
            ),
          ),
        ),
      ),
      // ),
    );
  }

  //button
  static buildButton(
      BuildContext context, VoidCallback opFunct, String text, bool isEdit) {
    return GestureDetector(
        onTap: isEdit ? opFunct : () {},
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10)),
          child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
              decoration: Utils.buildBoxDecoration(
                  context, 10, Theme.of(context).primaryColor),
              child: InkWell(
                splashColor: Colors.white,
                // color: Colors.cyan.shade600,
                // padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(30.0),
                // ),
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              )),
        ));
  }

  static buildLoginButton(
      BuildContext context, VoidCallback opFunct, String text) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.2)),
        onPressed: opFunct,
        child: Text(text));
    /* return Material(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        splashColor: Colors.white,
        onTap: opFunct, //startLogin,
        child: Container(
          color: Theme.of(context).primaryColor,
          // duration: const Duration(seconds: 1),
          width: 150,
          height: 50,
          alignment: Alignment.center,
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
              )),
        ),
      ),
    );*/
  }

  //pakage list_tile_switch: ^1.0.0
  static buildListTileSwitch(BuildContext context, IconData icon, bool value,
      String title, onChange, switchType) {
    return ListTileSwitch(
      leading: Icon(icon),
      switchActiveColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      switchScale: 0.8,
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      subtitle: value ? const Text('On') : const Text('Off'),
      value: value,
      switchType: switchType,
      onChanged: onChange,
    );
  }

  static buildAuthListTile(BuildContext context, available, IconData icon,
      bool value, String title, onChange, switchType) {
    return ListTileSwitch(
      leading: Icon(icon),
      switchActiveColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      switchScale: 0.8,
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      subtitle: available
          ? (value ? const Text('On') : const Text('Off'))
          : const Text('Your device not supportred'),
      value: available ? value : false,
      switchType: switchType,
      onChanged: onChange,
    );
  }

  static buildListTile(
      BuildContext context, IconData icon, String title, onChange) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onChange);
  }

  static buildBalanceDialog(BuildContext context, onAddBalance, width, height,
      profileImage, title, description, text) async {
    const double padding = 20;
    const double avatarRadius = 45;
    bool isDarkmode = await Webservice.prefgetBool('darkmode');
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(padding),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Center(
                child: Stack(children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(
                        left: padding,
                        top: avatarRadius + padding,
                        right: padding,
                        bottom: padding),
                    margin: const EdgeInsets.only(top: avatarRadius),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: isDarkmode
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(padding),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 3),
                              blurRadius: 20),
                        ]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (description != '')
                          SizedBox(
                            height: height * 0.002,
                          ),
                        if (description != '')
                          Text(
                            description,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        if (description != '')
                          SizedBox(
                            height: height * 0.002,
                          ),
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        buildEditText(context, true, Webservice.user.balance,
                            'Enter Budget', 'Edit Budget', (value) {
                          Webservice.newBalance = value;
                        }, 'Enter valid Budget'),
                        SizedBox(
                          height: height * 0.01,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: buildLoginButton(context, onAddBalance, text),
                        ),
                      ],
                    ),
                  ), // bottom part
                  if (profileImage != '')
                    Positioned(
                      left: padding,
                      right: padding,
                      child: buildProfileImagewithShadow(context, profileImage,
                          width * 0.8, height * 0.7, () {}),
                    )
                ]),
              ));
        });
  }

  Future buildConfirmationDialog(
      BuildContext context, String title, onCancel, onOKPressed) async {
    return showModalBottomSheet(
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(
            maxHeight: 300, minHeight: 300, minWidth: double.infinity),
        context: context,
        builder: (context) {
          return Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              elevation: 5,
              child: SizedBox(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.red, fontSize: 25),
                      ),
                      Text(
                        'Are you sure ?',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: onCancel,
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.cyan))),
                          TextButton(
                              onPressed: onOKPressed,
                              child: const Text('Ok',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.cyan)))
                        ],
                      )
                    ],
                  ),
                ),
              )));
        });
  }

  //update app
  static showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            icon: Icon(Icons.update,
                size: 30, color: Theme.of(context).primaryColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('App Update Available'),
            content: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'A new version of the app is available.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Please update for the latest features and improvements.',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              buildLoginButton(context, openPlayOrAppStore, 'Update Now')
            ],
          ),
        );
      },
    );
  }

  static void openPlayOrAppStore() {
    if (Platform.isAndroid || Platform.isIOS) {
      final appId = Platform.isAndroid ? 'com.vm.expense' : 'com.vm.expense';
      final url = Uri.parse(
        Platform.isAndroid
            ? "market://details?id=$appId"
            : "https://apps.apple.com/app/id$appId",
      );
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
