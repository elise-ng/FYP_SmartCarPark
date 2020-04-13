import 'package:flutter/material.dart';
import 'package:smart_car_park_app/models/parking_invoice.dart';
import 'package:smart_car_park_app/models/payment_method.dart';
import 'package:smart_car_park_app/pages/payment/add_credit_card_page.dart';
import 'package:smart_car_park_app/utils/cloud_functions_utils.dart';
import 'package:smart_car_park_app/widgets/progress_dialog.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

class CreditCardManagementPage extends StatefulWidget {
  final ParkingInvoice parkingInvoice;

  CreditCardManagementPage({
    this.parkingInvoice,
  });

  @override
  _CreditCardManagementPageState createState() =>
      _CreditCardManagementPageState();
}

class _CreditCardManagementPageState extends State<CreditCardManagementPage> {
  List<PaymentMethod> _paymentMethod = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ProgressDialog.show(context);
      await this._initCustomerSession();
      ProgressDialog.hide(context);
    });
  }

  Future<void> _initCustomerSession() async {
    CustomerSession.initCustomerSession(
        (apiVersion) => CloudFunctionsUtils.getEphemeralKey(apiVersion),
        apiVersion: "2020-03-02");
    List data = (await CustomerSession.instance.listPaymentMethods())["data"];
    setState(() {
      this._paymentMethod =
          data.map((map) => PaymentMethod.fromJson(map)).toList();
    });
  }

  void _addCard() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCreditCardPage(),
      ),
    );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Cards'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ListTileTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView.separated(
            itemCount: this._paymentMethod.length + 1,
            separatorBuilder: (_, __) => Divider(
              height: 2,
              thickness: 2,
            ),
            itemBuilder: (context, index) {
              if (index == this._paymentMethod.length) {
                return InkWell(
                  onTap: () {
                    this._addCard();
                  },
                  child: Container(
                    constraints: BoxConstraints(minHeight: 80),
                    alignment: Alignment.center,
                    child: ListTile(
                      leading: Icon(
                        Icons.payment,
                        size: 40,
                      ),
                      title: Text("Add Credit Card"),
                    ),
                  ),
                );
              } else {
                //TODO: existing card widget
                return Container(
                  constraints: BoxConstraints(minHeight: 80),
                  child: ListTile(
                    leading: Icon(
                      Icons.payment,
                      size: 40,
                    ),
                    title: Text("Credit Card"),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
