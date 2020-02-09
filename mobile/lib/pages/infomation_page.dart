import 'package:flutter/material.dart';
import 'package:smart_car_park_app/widgets/signin_widget.dart';

class InformationPage extends StatefulWidget {
  InformationPage({
    key,
  }) : super(key: key);

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {

  bool _isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text("_isSignedIn = ${_isSignedIn.toString()}"),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isSignedIn = !_isSignedIn;
            });
          },
        ),
      ),
      bottomSheet: _isSignedIn ? null : SigninWidget(),
    );
  }
}
