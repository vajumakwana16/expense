import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense/utils/webservice.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUtils {
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static final storageRef = FirebaseStorage.instance.ref();

  //users
  static final CollectionReference<Map<String, dynamic>> usersCollection =
      fireStore.collection("users");

  //transactions
  static final CollectionReference<Map<String, dynamic>>
      transactionsCollection = fireStore.collection("transactions");

  static uploadImage({required File file}) async {
    Reference reference = storageRef.child("profileImages/");
    //Upload the file to firebase
    UploadTask uploadTask = reference.putFile(file);
    // Waits till the file is uploaded then stores the download url
    await uploadTask.then((p0) async {
      final url = await p0.ref.getDownloadURL();
      await storageRef.child(Webservice.user.profileimage).delete();
      final user = Webservice.user.copy(profileimage: url.toString());
      Webservice.user = user;
      usersCollection.doc(user.id).set(user.toJson());
    });
  }
}
