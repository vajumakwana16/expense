import 'package:sms_autofill/sms_autofill.dart';

import '../providers/theme_previder.dart';
import '../providers/txn_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../utils/utils.dart';
import '../utils/webservice.dart';

enum Status { waithing, error }

class Varification extends StatefulWidget {
  const Varification({Key? key}) : super(key: key);

  @override
  State<Varification> createState() => _VarificationState();
  static const routeName = '/verification';
}

class _VarificationState extends State<Varification> {
  late SharedPreferences preferences;
  String name = '';
  String email = '';
  String phoneNumber = '';

  Map<String, String> userDetails = {'phone': ''};
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  var _verificationId;
  final _formKey = GlobalKey<FormState>();
  final controllerCode = TextEditingController();
  var resendToken;
  var status = Status.waithing;
  bool isLoading = false;

  var _initValues = {
    'code': '',
  };

  @override
  void initState() {
    if (Webservice.developerMode) {
      _initValues = {
        'code': '123456',
      };
    }
    listen();
    super.initState();
  }

  listen() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  void didChangeDependencies() {
    _initValues = {
      'code': '',
    };
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controllerCode.dispose();
    super.dispose();
  }

  var authType = '';
  String response = "";

  @override
  Widget build(BuildContext context) {
    final txnProvider = Provider.of<TxnProvider>(context, listen: true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    var authData = ModalRoute.of(context)!.settings.arguments as List;
    // print(authData.toString());
    authType = authData[0].toString();
    if (authType == 'Register') {
      name = authData[4];
      email = authData[5];

      userDetails['name'] = name.toString();
      userDetails['email'] = email.toString();
    }
    _verificationId = authData[2];
    phoneNumber = authData[3];
    resendToken = authData[1];
    userDetails['phone'] = phoneNumber.toString();

    //print(_verificationId);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode
          ? Theme.of(context).primaryColor
          : Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 30),
              //image
              Hero(
                  tag: 'tag',
                  child: Image.asset("assets/images/code_verification.jpeg",
                      fit: BoxFit.cover)),

              const SizedBox(height: 30),

              buildTitle('Code Verification'),
              const SizedBox(height: 50),

              Center(child: Text('Enter Code Sent to $phoneNumber')),
              const SizedBox(height: 25),
              //enter code
              PinFieldAutoFill(
                  // decoration: // UnderlineDecoration, BoxLooseDecoration or BoxTightDecoration see https://github.com/TinoGuo/pin_input_text_field for more info,
                  currentCode: controllerCode.text, // prefill with a code
                  onCodeSubmitted: (code) {
                    controllerCode.text = code;
                    setState(() {});
                  }, //code submitted callback
                  onCodeChanged: (code) {
                    controllerCode.text = code!;
                    setState(() {});
                  }, //code changed callback
                  codeLength: 6 //code length, default 6
                  ),
              /* buildformfield(
                controllerCode,
                'Enter Code',
                const Icon(Icons.lock, size: 26),
                (code) {
                  if (code!.isEmpty) {
                    return 'Please Enter Code';
                  } else if (code.toString().length < 6) {
                    return 'Enter Valid Code';
                  }
                  return null;
                },
              ),*/
              const SizedBox(height: 24),

              //submit
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Utils.buildLoginButton(context, () async {
                        if (_formKey.currentState!.validate()) {
                          FocusScope.of(context).unfocus();
                          _initValues['code'] = controllerCode.text;

                          if (Webservice.developerMode) {
                            if (authType == 'Register') {
                              await userProvider
                                  .register(context, null, Webservice.cntCode,
                                      phoneNumber, name, email)
                                  .then((value) {
                                if (value == true) {
                                  txnProvider.clearList();
                                  showSuccessSnack(
                                      context, 'Registered Successfully');
                                  Navigator.of(context)
                                      .pushReplacementNamed(Approutes.main);
                                } else {
                                  Utils.showErrorDialog(
                                      context, value.toString());
                                }
                              });
                            } else {
                              await userProvider
                                  .login(context, null, phoneNumber)
                                  .then((value) {
                                if (value == true) {
                                  txnProvider.clearList();
                                  showSuccessSnack(
                                      context, 'Login Successfully');
                                  Navigator.of(context)
                                      .pushReplacementNamed(Approutes.main);
                                } else {
                                  Utils.showErrorDialog(
                                      context, value.toString());
                                }
                              });
                            }
                          } else {
                            if (_verificationId != null) {
                              setState(() => isLoading = true);

                              var credential =
                                  auth.PhoneAuthProvider.credential(
                                      verificationId: _verificationId,
                                      smsCode: controllerCode.text);

                              final result =
                                  await _auth.signInWithCredential(credential);
                              if (result.user != null) {
                                if (authType == 'Register') {
                                  await userProvider
                                      .register(
                                          context,
                                          result.user ?? null,
                                          Webservice.cntCode,
                                          phoneNumber,
                                          name,
                                          email)
                                      .then((value) {
                                    if (value == true) {
                                      txnProvider.clearList();
                                      showSuccessSnack(
                                          context, 'Registered Successfully');
                                      Navigator.of(context)
                                          .pushReplacementNamed(Approutes.main);
                                    } else {
                                      Utils.showErrorDialog(
                                          context, value.toString());
                                    }
                                  });
                                } else {
                                  await userProvider
                                      .login(context, result.user!, phoneNumber)
                                      .then((value) {
                                    if (value == true) {
                                      txnProvider.clearList();
                                      showSuccessSnack(
                                          context, 'Login Successfully');
                                      Navigator.of(context)
                                          .pushReplacementNamed(Approutes.main);
                                    } else {
                                      Utils.showErrorDialog(
                                          context, value.toString());
                                    }
                                  });
                                }
                              } else {
                                ShowErrorDialog("Something went wrong");
                              }

                              setState(() => isLoading = false);
                            }
                          }
                        }
                      }, 'Verify Code'),
              ),
              const SizedBox(
                height: 20,
              ),

              //have account ?
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Center(child: Text('Didn\'t Recieve Code ?')),

                const SizedBox(height: 1),

                //sign in
                Center(
                    child: TextButton(
                  child: const Text('Resend Code'),
                  onPressed: () async {
                    await _verifyPhoneNumber();
                  },
                ))
              ]),
            ],
          ),
        ),
      ),
    );
  }

  //build title
  Widget buildTitle(String title) {
    return Center(
        child: Text(
      title,
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold),
    ));
  }

  //build listTile
  Widget buildformfield(TextEditingController controllerName, String label,
      Icon icon, FormFieldValidator validator) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      textCapitalization: TextCapitalization.words,
      controller: controllerName,
      decoration: decoration(Text(label), label, icon),
      validator: validator,
      keyboardType: TextInputType.number,
      //obscureText: label == 'Password' ? true : false,
    );
  }

  //editText Decoration
  InputDecoration decoration(Widget label, String inputName, Icon icon) =>
      InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          alignLabelWithHint: true,
          label: label,
          prefixIcon: icon,
          prefixIconColor: Theme.of(context).primaryColor);

  //show snackbar
  showSuccessSnack(BuildContext context, String msg) {
    showTopSnackBar(
      context,
      CustomSnackBar.success(
        message: msg.isEmpty ? 'Somthing Went Wrong!' : msg,
      ),
    );
  }

  //verify code
  // Future _sendCodetoFireBase(
  //     BuildContext context, String _verificationId, String code) async {
  //   if (_verificationId != null) {
  //     var credential = PhoneAuthProvider.credential(
  //         verificationId: _verificationId, smsCode: code);

  //     await _auth
  //         .signInWithCredential(credential)
  //         .then((value) {
  //           showSuccessSnack(context, 'Login Successflly');
  //           final userProvider = Provider.of<UserProvider>(context);
  //           if (authType == 'Register') {
  //             userProvider
  //                 .register(
  //                     context, Webservice.cntCode, phoneNumber, name, email)
  //                 .then((value) {
  //               Utils.buildSnackbar(context, value.toString());
  //             });
  //           } else {
  //             userProvider.login(context, phoneNumber).then((value) {
  //               Utils.buildSnackbar(context, value.toString());
  //             });
  //           }
  //           //ShowErrorDialog(value.toString());
  //         })
  //         .whenComplete(() {})
  //         .catchError((error) {
  //           ShowErrorDialog(error.toString());
  //         })
  //         .onError((error, stackTrace) {
  //           throw error.toString();
  //         })
  //         .then((value) async {
  //           if (value.toString().isEmpty || value == null) {
  //             // await Preference.setUserDetails(name, email, phoneNumber)
  //             //     .then((_) async {
  //             //   await preferences.setInt('isLogin', 1).then((_) {
  //             //     Navigator.of(context)
  //             //         .pushReplacementNamed(HomeWidget.routeName);
  //             //   });
  //             // });
  //           } else {
  //             ShowErrorDialog(value.toString());
  //           }
  //         });
  //   }
  // }

  //resend code
  Future _verifyPhoneNumber() async {
    _auth.verifyPhoneNumber(
        phoneNumber: '+91' + phoneNumber.toString(),
        verificationCompleted: (phoneAuthCredential) async {
          //ShowErrorDialog(phoneAuthCredential.toString());
        },
        verificationFailed: (verificationFailed) async {
          ShowErrorDialog(verificationFailed.toString());
        },
        codeSent: (verificationId, resendToken) async {
          showSuccessSnack(context, 'Code Sent');
        },
        codeAutoRetrievalTimeout: (verificationId) async {
          //ShowErrorDialog('Time Out');
        });
  }

  ShowErrorDialog(String error) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(error.toString()),
              actions: [
                TextButton(
                    onPressed: () => {Navigator.of(context).pop()},
                    child: const Text('Okay'))
              ],
            ));
  }
}
