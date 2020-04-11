import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_car_park_app/global_variables.dart';
import 'package:smart_car_park_app/home_page.dart';
import 'package:smart_car_park_app/utils/user_utils.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    this._init();
  }

  void _init() async {
    await this._initUserState();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  Future<void> _initUserState() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if(user != null) {
      userRecord.update(await UserUtils.getUserRecordDocument(user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
    );
  }
}
