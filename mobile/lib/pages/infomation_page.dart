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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        child: Text("Login"),
        color: Colors.blueAccent,
        textColor: Colors.white,
        onPressed: () {
          showBottomSheet(
            context: context,
            builder: (context) => SigninWidget()
          );
        },
      ),
    );
  }
}
