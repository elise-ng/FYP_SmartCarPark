import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_car_park_app/pages/payment/pay_inperson.dart';
import 'package:smart_car_park_app/pages/payment/credit_card.dart';

class PaymentMethodPage extends StatefulWidget {
  String gateRecordId;
  int fee;

  PaymentMethodPage({
    key,
    gateRecordId,
    fee,
  })  : this.gateRecordId = gateRecordId,
        this.fee = fee,
        super(key: key);

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Payment method'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              child: Text("Credit Card", style: TextStyle(fontSize: 16)),
              onPressed: () {
                this._pushRoute(
                  CardPage(
                    gateRecordId: widget.gateRecordId,
                    fee: widget.fee,
                  ),
                );
              },
            ),
            Divider(),
            RaisedButton(
              child: Text(
                Platform.isIOS ? "Apple Pay" : "Google Pay",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                this._performNativePayment();
              },
            ),
            RaisedButton(
              child: Text(
                "Alipay",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {},
            ),
            RaisedButton(
              child: Text(
                "WeChatpay",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {},
            ),
            Divider(),
            RaisedButton(
              child: Text("Pay in Security Center",
                  style: TextStyle(fontSize: 16)),
              onPressed: () {
                this._pushRoute(
                  PayInPersonPage(
                    gateRecordId: widget.gateRecordId,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pushRoute(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  void _performNativePayment() {
    //TODO
  }
}
