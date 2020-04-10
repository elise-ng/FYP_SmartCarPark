import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car_park_app/pages/payment/pay_inperson.dart';
import 'package:smart_car_park_app/pages/payment/credit_card.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:uni_links/uni_links.dart';

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
              onPressed: () {
                this._performAlipay();
              },
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
//    StripePayment.paymentRequestWithNativePay(
//      androidPayOptions: AndroidPayPaymentRequest(
//        total_price: "90",
//        currency_code: "HKD",
//      ),
//      applePayOptions: ApplePayPaymentOptions(
//        currencyCode: 'HKD',
//        items: [
//          ApplePayItem(
//            label: 'Pay',
//            amount: '90',
//          )
//        ],
//      ),
//    );
  }

  void _performAlipay() {
    StripePayment.createSourceWithParams(
      SourceParams(
        type: 'alipay',
        amount: 6000,
        currency: 'HKD',
        returnURL: 'smartcarpark://safepay/',
      ),
    );
  }
}
