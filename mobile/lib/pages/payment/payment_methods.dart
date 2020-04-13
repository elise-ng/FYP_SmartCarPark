import 'package:flutter/material.dart';
import 'package:smart_car_park_app/models/parking_invoice.dart';
import 'package:smart_car_park_app/models/payment_intent.dart';
import 'package:smart_car_park_app/pages/payment/credit_card_management_page.dart';
import 'package:smart_car_park_app/pages/payment/pay_inperson.dart';
import 'package:smart_car_park_app/utils/cloud_functions_utils.dart';
import 'package:smart_car_park_app/widgets/parking_invoice_widget.dart';
import 'package:smart_car_park_app/widgets/progress_dialog.dart';

class PaymentMethodsPage extends StatefulWidget {
  final String gateRecordId;

  PaymentMethodsPage({
    key,
    this.gateRecordId,
  }) : super(key: key);

  @override
  _PaymentMethodsPageState createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  PaymentIntent _paymentIntent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ProgressDialog.show(context);
      await this._getParkingFeeReceipt();
      ProgressDialog.hide(context);
    });
  }

  Future<void> _getParkingFeeReceipt() async {
    PaymentIntent _intent =
        await CloudFunctionsUtils.createPaymentIntent("oROtC7Jsw2APdIp2zn3e");
    setState(() {
      this._paymentIntent = _intent;
    });
  }

  Widget _getDivider() {
    return Divider(
      height: 2,
      thickness: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (this._paymentIntent.invoice != null)
              Expanded(
                child: ParkingInvoiceWidget(
                  invoice: this._paymentIntent.invoice,
                ),
              ),
            ListTileTheme(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  this._getDivider(),
                  ListTile(
                    onTap: () {
                      this._handleCreditCardPayment();
                    },
                    leading: Icon(
                      Icons.payment,
                      size: 40,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text("Credit Cards"),
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

  void _handleCreditCardPayment() async {
    this._pushRoute(
      CreditCardManagementPage(
        paymentIntent: this._paymentIntent,
      ),
    );
  }

  void _payByAlipay() {
    // TODO:
  }

  void _payByWeChatPay() {
    // TODO:
  }
}
