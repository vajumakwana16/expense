import '../providers/theme_previder.dart';
import '../providers/txn_provider.dart';
import '../providers/user_provider.dart';
import '../utils/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  static const routeName = '/varification';
}

class _VarificationState extends State<Varification> {
  late SharedPreferences preferences;
  String name = '';
  String email = '';
  String phoneNumber = '';

  Map<String, String> userDetails = {'phone': ''};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _verificationId;
  final _formKey = GlobalKey<FormState>();
  final controllerCode = TextEditingController();
  var resendToken;
  var status = Status.waithing;

  var _initValues = {
    'code': '',
  };

  @override
  void initState() {
    super.initState();
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

              buildTitle('Code Varification'),
              const SizedBox(height: 50),

              Center(
                child: Text('Enter Code Sent to $phoneNumber'),
              ),
              const SizedBox(height: 20),
              //enter code
              buildformfield(
                controllerCode,
                'Enter Code',
                const Icon(
                  Icons.lock,
                  size: 26,
                ),
                (code) {
                  if (code!.isEmpty) {
                    return 'Please Enter Code';
                  } else if (code.toString().length < 6) {
                    return 'Enter Valid Code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              //submit
              Center(
                child: Utils.buildButton(context, () async {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                    _initValues['code'] = controllerCode.text;
                    // _sendCodetoFireBase(context, _verificationId,
                    //     controllerCode.text.toString());

                    if (_verificationId != null) {
                      var credential = PhoneAuthProvider.credential(
                          verificationId: _verificationId,
                          smsCode: controllerCode.text);

                      await _auth
                          .signInWithCredential(credential)
                          .then((value) {
                            if (authType == 'Register') {
                              userProvider
                                  .register(context, Webservice.cntCode,
                                      phoneNumber, name, email)
                                  .then((value) {
                                if (value == true) {
                                  txnProvider.clearList();
                                  showSuccessSnack(
                                      context, 'Registerd Successflly');
                                  Navigator.of(context)
                                      .pushReplacementNamed(Approutes.main);
                                } else {
                                  Utils.showErrorDialog(
                                      context, value.toString());
                                }
                              });
                            } else {
                              userProvider
                                  .login(context, phoneNumber)
                                  .then((value) {
                                if (value == true) {
                                  txnProvider.clearList();
                                  showSuccessSnack(
                                      context, 'Login Successflly');
                                  Navigator.of(context)
                                      .pushReplacementNamed(Approutes.main);
                                } else {
                                  Utils.showErrorDialog(
                                      context, value.toString());
                                }
                              });
                            }
                            //ShowErrorDialog(value.toString());
                          })
                          .whenComplete(() {})
                          .catchError((error) {
                            ShowErrorDialog(error.toString());
                          })
                          .onError((error, stackTrace) {
                            Utils.buildSnackbar(context, error.toString());
                          })
                          .then((value) async {
                            if (value.toString().isEmpty || value == null) {
                              // await Preference.setUserDetails(name, email, phoneNumber)
                              //     .then((_) async {
                              //   await preferences.setInt('isLogin', 1).then((_) {
                              //     Navigator.of(context)
                              //         .pushReplacementNamed(HomeWidget.routeName);
                              //   });
                              // });
                            } else {
                              ShowErrorDialog(value.toString());
                            }
                          });
                    }
                  }
                }, 'Verify Code', true),
              ),
              const SizedBox(
                height: 20,
              ),

              const Spacer(),

              //have account ?
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Center(child: Text('Didn\'t Recieve Code ?')),

                const SizedBox(
                  height: 1,
                ),

                //sign in
                TextButton(
                    onPressed: () {
                      setState(() {
                        // if (_authMode == AuthMode.Signup) {
                        //   _authMode = AuthMode.Login;
                        // } else {
                        //   _authMode = AuthMode.Signup;
                        // }
                      });
                    },
                    child: Center(
                        child: TextButton(
                      child: const Text('Resend Code'),
                      onPressed: () async {
                        await _verifyPhoneNumber();
                      },
                    )))
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
