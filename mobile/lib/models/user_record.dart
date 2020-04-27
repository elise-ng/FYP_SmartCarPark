import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRecord with ChangeNotifier{
  String uid;
  String phoneNumber;
  String stripeCustomerId;

  void update(DocumentSnapshot snapshot) {
    if(snapshot == null || !snapshot.exists) {
      reset();
      return;
    }

    this.uid = snapshot.documentID;
    this.phoneNumber = snapshot.data["phoneNumber"];
    this.stripeCustomerId = snapshot.data["stripe_customerId"];
    this.notifyListeners();
  }

  void reset() {
    this.uid = null;
    this.phoneNumber = null;
    this.stripeCustomerId = null;
    this.notifyListeners();
  }

  bool isEmpty() => this.uid == null;
}