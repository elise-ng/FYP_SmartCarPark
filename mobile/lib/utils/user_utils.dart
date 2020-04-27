import 'package:cloud_firestore/cloud_firestore.dart';

class UserUtils {
  static Future<DocumentSnapshot> getUserRecordDocument(String uid, {Source source}) async {
    if(source != null) {
      return Firestore.instance.collection("userRecords").document(uid).get(source: source);
    } else {
      return Firestore.instance.collection("userRecords").document(uid).get();
    }
  }
}