import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PayInPersonPage extends StatefulWidget {
  PayInPersonPage({
    key,
  }) : super(key: key);

  @override
  _PayInPersonPageState createState() => _PayInPersonPageState();
}

class _PayInPersonPageState extends State<PayInPersonPage> {
  String carPlateNum = "PK12345";
    String parkingLocation = "LG3-12";
    int parkingDuation = 130;
    
  @override
  Widget build(BuildContext context) {
    String phoneNum = "98765432";
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Payments'),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
                  onPressed: () {
              },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(child: QrImage(
              data: phoneNum,
              version: QrVersions.auto,
              size: 300,
              gapless: false,
            ),
            ),
            Text("Please pay cash in Security Center", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
