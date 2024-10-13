import '../../providers/theme_previder.dart';
import '../../providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/utils.dart';
import '../../utils/webservice.dart';

enum AuthMode { Signup, Login }

class ScreenAuthentication extends StatefulWidget {
  const ScreenAuthentication({Key? key}) : super(key: key);

  @override
  State<ScreenAuthentication> createState() => _ScreenAuthenticationState();
  static const routeName = '/authentication';
}

class _ScreenAuthenticationState extends State<ScreenAuthentication> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            /*background*/
            Container(
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
            ),
            /*logo - image */
            const SingleChildScrollView(
              child: AuthCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  SharedPreferences? preferences;
  String? userPhone;

  var _isLoading = false;
  var validator = [
    //name
    (name) {
      if (name!.isEmpty) {
        return 'Please enter name';
      }
      return null;
    },
    //email
    (phone) {
      if (phone!.isEmpty) {
        return 'Please enter phone';
      } else if (phone.toString().length < 10) {
        return 'Please valid phone';
      }
      return null;
    },
    //email
    (password) {
      if (password!.isEmpty) {
        return 'Please enter email';
      }
      return null;
    }
  ];

  AuthMode _authMode = AuthMode.Signup;

  var _initValues = {
    'name': '',
    'email': '',
    'phone': '',
  };

  final _formKey = GlobalKey<FormState>();
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPhone = TextEditingController();

  @override
  void didChangeDependencies() {
    _initValues = {
      'name': '',
      'email': '',
      'phone': '',
    };
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerEmail.dispose();
    controllerPhone.dispose();
    super.dispose();
  }

  double cwidth = 400;
  double cheight = 500;

  @override
  void initState() {
    if (Webservice.developerMode) controllerPhone.text = "9537962565";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final mediaQuery = MediaQuery.of(context).size;
    final height = mediaQuery.height;
    final width = mediaQuery.width;

    if (_authMode == AuthMode.Signup) {
      cwidth = width * 0.9;
      cheight = height * 0.85;
    } else {
      cwidth = width * 0.9;
      cheight = height * 0.60;
    }

    loginOrsignUp() {
      FocusScope.of(context).unfocus();
      if (_formKey.currentState!.validate()) {
        _initValues['phone'] = controllerPhone.text;
        _initValues['name'] = controllerName.text;
        _initValues['email'] = controllerEmail.text;

        setState(() {
          _isLoading = true;
        });

        userProvider
            .checkPhoneExist(_initValues['phone'].toString())
            .then((value) async {
          if (value == true) {
            if (isSigUp()) {
              Utils.buildshowTopSnackBar(context, Icons.no_accounts,
                  'Account Already Exist\nPlease Sign in', 'error');
              setState(() => _isLoading = false);
            } else {
              // Utils.buildshowTopSnackBar(
              //     context, Icons.account_circle, 'Loging you', 'success');
              userProvider
                  .verifyPhoneWithFirebase(context, Webservice.cntCode, "", "",
                      controllerPhone.text, 1)
                  .then((v) {
                setState(() => _isLoading = false);
              });
            }
          } else {
            if (isSigUp()) {
              Utils.buildshowTopSnackBar(
                  context, Icons.account_circle, 'Creating Account', 'success');
              userProvider
                  .verifyPhoneWithFirebase(
                      context,
                      Webservice.cntCode,
                      controllerName.text,
                      controllerEmail.text,
                      controllerPhone.text,
                      0)
                  .then((v) {
                setState(() => _isLoading = false);
              });
            } else {
              Utils.buildshowTopSnackBar(
                  context, Icons.no_accounts, 'Account Not Exist', 'error');
              setState(() => _isLoading = false);
            }
          }
        });
      }
    }

    return SafeArea(
      child: AnimatedContainer(
        width: cwidth,
        height: cheight,
        curve: Curves.bounceOut,
        duration: const Duration(seconds: 1),
        child: Card(
          color: themeProvider.isDarkMode
              ? Theme.of(context).primaryColor
              : Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Colors.white),
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Center(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(height * 0.03),
                child: SingleChildScrollView(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.003),

                      //create account
                      isSigUp()
                          ? buildTitle('Create Account')
                          : buildTitle('Log In'),

                      SizedBox(height: height * 0.003),
                      Hero(
                          tag: 'tag',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset("assets/images/img_login.jpeg",
                                fit: BoxFit.cover),
                          )),
                      SizedBox(height: height * 0.01),
                      //name
                      isSigUp()
                          ? buildformfield(controllerName, 'Username',
                              const Icon(Icons.person), validator[0])
                          : Container(),

                      SizedBox(height: height * 0.01),

                      //phone
                      buildformfield(controllerPhone, 'Phone',
                          const Icon(Icons.phone), validator[1]),

                      SizedBox(height: height * 0.01),
                      //email
                      isSigUp()
                          ? Column(children: [
                              buildformfield(
                                  controllerEmail,
                                  'Email',
                                  const Icon(
                                    Icons.lock,
                                    size: 26,
                                  ),
                                  validator[2]),
                              SizedBox(height: height * 0.04),
                            ])
                          : Container(),

                      //submit
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Utils.buildLoginButton(
                              context,
                              loginOrsignUp,
                              _authMode == AuthMode.Signup
                                  ? 'Sign Up'
                                  : 'Request Code'),

                      SizedBox(height: height * 0.001),

                      //have account ?
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: _authMode == AuthMode.Signup
                                    ? const Text('Already have an account ?')
                                    : const Text('Not have an account ?')),

                            SizedBox(height: height * 0.003),

                            //sign in
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (_authMode == AuthMode.Signup) {
                                      _authMode = AuthMode.Login;
                                    } else {
                                      _authMode = AuthMode.Signup;
                                    }
                                  });
                                },
                                child: Center(
                                    child: _authMode == AuthMode.Signup
                                        ? const Text('Sign In')
                                        : const Text('Sign Up')))
                          ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitle(String title) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  //build formfeild
  Widget buildformfield(TextEditingController controllerName, String label,
      Icon icon, FormFieldValidator validator) {
    return TextFormField(
      textAlignVertical: TextAlignVertical.center,
      textCapitalization: TextCapitalization.words,
      controller: controllerName,
      decoration: decoration(Text(label), label, icon),
      validator: validator,
      keyboardType:
          label == 'Phone' ? TextInputType.phone : TextInputType.emailAddress,
      maxLength: label == 'Phone' ? 10 : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      //obscureText: label == 'Password' ? true : false,
    );
  }

  //editText Decoration
  InputDecoration decoration(Widget label, String inputName, Icon icon) =>
      InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.all(20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          alignLabelWithHint: true,
          label: label,
          prefixIcon: icon,
          prefixIconColor: Theme.of(context).primaryColor);

  isSigUp() {
    if (_authMode == AuthMode.Signup) {
      return true;
    }
    return false;
  }
}
