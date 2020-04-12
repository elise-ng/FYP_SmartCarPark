import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_car_park_app/pages/payment/pay_inperson.dart';
import 'package:smart_car_park_app/pages/payment/credit_card.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

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
  Widget _getDivider() {
    return Divider(
      height: 2,
      thickness: 2,
    );
  }

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
      body: ListTileTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            this._getDivider(),
            ListTile(
              onTap: () {
                this._pushRoute(
                  CardPage(
                    gateRecordId: widget.gateRecordId,
                    fee: widget.fee,
                  ),
                );
              },
              leading: Icon(
                Icons.payment,
                size: 40,
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text("Credit Card"),
            ),
            this._getDivider(),
            ListTile(
              onTap: this._payByAlipay,
              leading: Image(
                width: 40,
                height: 40,
                image: AssetImage("assets/alipay.png"),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text("Alipay"),
            ),
            this._getDivider(),
            ListTile(
              onTap: this._payByWeChatPay,
              leading: Image(
                width: 40,
                height: 40,
                image: AssetImage("assets/wechatpay.png"),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text("WeChat Pay"),
            ),
            this._getDivider(),
            ListTile(
              onTap: () {
                this._pushRoute(
                  PayInPersonPage(
                    gateRecordId: widget.gateRecordId,
                  ),
                );
              },
              leading: Icon(
                Icons.face,
                size: 40,
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text("Pay in Security Center"),
            ),
            this._getDivider(),
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

  void _payByAlipay() {
    // TODO:
  }

  void _payByWeChatPay() {
    // TODO:
  }
}
