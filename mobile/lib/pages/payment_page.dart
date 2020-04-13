import 'package:flutter/material.dart';
import 'package:smart_car_park_app/pages/payment/payment_methods.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({
    key,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String carPlateNum = "PK12345";
  String parkingLocation = "LG3-12";
  int parkingDuation = 130;
  String gateRecordId = "qwer1234";

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Payments'),
          // leading: new IconButton(
          //   icon: new Icon(Icons.arrow_back),
          //         onPressed: () {
          //     },
          // ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(40),
          children: <Widget>[
            Text("Car Plate Number\n", style: TextStyle(fontSize: 20)),
            Text(carPlateNum, style: TextStyle(fontSize: 16)),
            Divider(),
            Text("\nParking Location\n", style: TextStyle(fontSize: 20)),
            Text(parkingLocation, style: TextStyle(fontSize: 16)),
            Divider(),
            Text("\nParking Duration\n", style: TextStyle(fontSize: 20)),
            Text(parkingDuation.toString() + " minutes",
                style: TextStyle(fontSize: 16)),
            Divider(),
            Text("\nParking Fees\n", style: TextStyle(fontSize: 20)),
            Text("HKD " + ((parkingDuation / 60).ceil() * 20).toString(),
                style: TextStyle(fontSize: 16)),
            Divider(),
            Align(
              child: SizedBox(
                width: 240,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Proceed with the Payment"),
                      Icon(Icons.navigate_next)
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentMethodsPage(
                          gateRecordId: gateRecordId,
                        ),
                      ),
                    );
                  },
                  splashColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
