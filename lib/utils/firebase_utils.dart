import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense/utils/webservice.dart';

class FirebaseUtils {
  static final CollectionReference<Map<String, dynamic>> usersCollection =
      Webservice.fireStore.collection("users");
}
