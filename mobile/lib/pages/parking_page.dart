import 'package:flutter/material.dart';

class ParkingPage extends StatefulWidget {
  ParkingPage({
    key,
  }) : super(key: key);

  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Imagine this is a parking lot map"),
    );
  }
}
