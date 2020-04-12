import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_car_park_app/models/parking_invoice.dart';
import 'package:smart_car_park_app/pages/payment/credit_card_management_page.dart';
import 'package:smart_car_park_app/pages/payment/pay_inperson.dart';
import 'package:smart_car_park_app/utils/cloud_functions_utils.dart';
import 'package:smart_car_park_app/widgets/progress_dialog.dart';

class PaymentSummaryPage extends StatefulWidget {
  String gateRecordId;
  int fee;

  PaymentSummaryPage({
    key,
    gateRecordId,
    fee,
  })  : this.gateRecordId = gateRecordId,
        this.fee = fee,
        super(key: key);

  @override
  _PaymentSummaryPageState createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  ParkingInvoice _invoice;

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
    ParkingInvoice invoice = await CloudFunctionsUtils.getParkingInvoice("oROtC7Jsw2APdIp2zn3e");
    setState(() {
      this._invoice = invoice;
    });
  }

  Widget _getDivider() {
    return Divider(
      height: 2,
      thickness: 2,
    );
  }

  Widget _getParkingInvoiceWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    this._invoice.license,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Icon(Icons.access_time),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    "${this._invoice.durationInMinutes} minutes",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 2,
            thickness: 2,
            color: Colors.grey[600],
          ),
          Expanded(
            child: Column(
              children: this
                  ._invoice
                  .items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${item.quantity} x \$${item.fee}",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            "\$${item.subtotal}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Divider(
            height: 2,
            thickness: 2,
            color: Colors.grey[600],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Total",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Text(
                  "\$${this._invoice.total}",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            if (this._invoice != null)
              Expanded(child: this._getParkingInvoiceWidget()),
            ListTileTheme(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  this._getDivider(),
                  ListTile(
                    onTap: () {
                      this._pushRoute(
                        CreditCardManagementPage(
                          parkingInvoice: this._invoice,
                        ),
                      );
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

  void _payByAlipay() {
    // TODO:
  }

  void _payByWeChatPay() {
    // TODO:
  }
}
