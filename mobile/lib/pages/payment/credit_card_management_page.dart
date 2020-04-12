import 'package:flutter/material.dart';
import 'package:smart_car_park_app/models/parking_invoice.dart';
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
    CustomerSession.initCustomerSession((apiVersion) => CloudFunctionsUtils.getEphemeralKey(apiVersion), apiVersion: "2020-03-02");
    print(await CustomerSession.instance.listPaymentMethods());
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
        child: Column(

        ),
      ),
    );
  }
}
