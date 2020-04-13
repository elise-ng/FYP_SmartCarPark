import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:smart_car_park_app/models/payment_intent.dart';
import 'package:smart_car_park_app/models/payment_method.dart';
import 'package:smart_car_park_app/pages/payment/payment_complete_page.dart';
import 'package:smart_car_park_app/widgets/parking_invoice_widget.dart';
import 'package:smart_car_park_app/widgets/progress_dialog.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentSummaryPage extends StatefulWidget {
  /// Used for card payment
  final PaymentIntent paymentIntent;
  final Function updateCreditCards;

  /// Used for Alipay / WechatPay
//  final PaymentSource source;
  final PaymentMethod paymentMethod;

  PaymentSummaryPage({
    this.paymentIntent,
    this.updateCreditCards,
    this.paymentMethod,
  });

  @override
  _PaymentSummaryPageState createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  bool _needUpdateCreditCards() => widget.updateCreditCards != null;

  bool _isUsingPaymentIntent() => widget.paymentIntent != null;

  Future<bool> _pop() async {
    if (this._needUpdateCreditCards()) {
      widget.updateCreditCards();
    }
    return true;
  }

  void _pay() async {
    Map<String, dynamic> response;
    ProgressDialog.show(context, message: "Confirming payment...");
    if (this._isUsingPaymentIntent()) {
      response = await Stripe.instance.confirmPayment(
          widget.paymentIntent.clientSecret, widget.paymentMethod.id);
      await closeWebView();
    }
    ProgressDialog.hide(context);
    this._handlePaymentResponse(response);
  }

  void _handlePaymentResponse(Map<String, dynamic> response) {
    if (response["status"] == "succeeded") {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => PaymentCompletePage(
            invoice: widget.paymentIntent.invoice,
          ),
        ),
        ModalRoute.withName("/home"),
      );
    } else {
      showPlatformDialog(
        context: context,
        builder: (_) => BasicDialogAlert(
          title: Text("Current Location Not Available"),
          content:
              Text("Your current location cannot be determined at this time."),
          actions: <Widget>[
            BasicDialogAction(
              title: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }

  String _getPaymentMethodText() {
    if (widget.paymentMethod != null) {
      return widget.paymentMethod.card.getCardDescription();
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this._pop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Confirmation'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: ParkingInvoiceWidget(
                  invoice: widget.paymentIntent.invoice,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Pay with ${this._getPaymentMethodText()}"),
                      Icon(Icons.navigate_next)
                    ],
                  ),
                  onPressed: this._pay,
                  splashColor: Colors.indigoAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
