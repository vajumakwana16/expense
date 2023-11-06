// import 'package:file_picker_pro/file_data.dart';
// import 'package:file_picker_pro/file_picker.dart';
// import 'package:file_picker_pro/files.dart';

// import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../providers/user_provider.dart';
import '../utils/utils.dart';
import '../utils/webservice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/focus_unscop_widget.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = Webservice.name;
  String phone = Webservice.phone;
  String email = Webservice.email;
  String profileImage = Webservice.profileimage;

  /*onImageTap() {
    Utils.buildshowTopSnackBar(
        context, Icons.image, 'Profile Image Updated', 'success');
  }*/

  onChangeName(value) {
    name = value;
  }

  onChangeEmail(value) {
    email = value;
  }

  @override
  void initState() {
    Webservice.initUser();
    super.initState();
  }

  final ImagePicker picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    profileImage = Webservice.profileimage;

    print("profileImage");
    print(profileImage);
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;
    final isDarkmode = Theme.of(context).brightness == Brightness.dark;
    final updateProvider = Provider.of<UserProvider>(context);
    // const profileImage ="https://lh3.googleusercontent.com/a-/AFdZucquZ3hfPTJU6LIoagydnVbx5z4DE0uImjHMvjwn1A=s288-p-rw-no";

    return UnFocusPage(
      child: Scaffold(
        backgroundColor:
            isDarkmode ? Theme.of(context).primaryColor : Webservice.bgColor,
        appBar: Utils.buildAppbar(context, 'Profile'),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          children: [
            Utils.buildProfileImagewithShadow(
                context, profileImage, height * 0.7, width * 0.35, () async {
              final result =
                  await picker.pickImage(source: ImageSource.gallery);
              if (result != null) {
                final path = result.path;
                await updateProvider
                    .updateProfileImage(context, File(path))
                    .then((value) => setState(() {}));
              }
            }),
            Container(
                padding: EdgeInsets.only(left: height * 0.02),
                decoration:
                    Utils.buildBoxDecoration(context, 10, Webservice.bgColor!),
                child: Utils.buildEditText(context, true, name, 'Enter Name',
                    'Name', onChangeName, 'Enter valid name')),
            Utils.sizedBox(height * 0.1, 0.2),
            Container(
                padding: EdgeInsets.only(left: height * 0.02),
                decoration:
                    Utils.buildBoxDecoration(context, 10, Webservice.bgColor!),
                child: Utils.buildEditText(context, false, phone, 'Enter Phone',
                    'Phone', (value) {}, 'Enter valid phone')),
            Utils.sizedBox(height * 0.1, 0.2),
            Container(
                padding: EdgeInsets.only(left: height * 0.02),
                decoration:
                    Utils.buildBoxDecoration(context, 10, Webservice.bgColor!),
                child: Utils.buildEditText(context, true, email, 'Enter Email',
                    'Email', onChangeEmail, 'Enter valid email')),
            Utils.sizedBox(height * 0.1, 0.5),
            Center(
              child: Utils.buildLoginButton(context, () async {
                if (name.isNotEmpty && email.isNotEmpty) {
                  await updateProvider.updateProfile(context, name, email);
                }
              }, 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
