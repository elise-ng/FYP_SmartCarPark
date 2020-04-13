import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_car_park_app/models/parking_invoice.dart';

class PaymentCompletePage extends StatefulWidget {
  final ParkingInvoice invoice;

  PaymentCompletePage({
    this.invoice,
  });

  @override
  _PaymentCompletePageState createState() => _PaymentCompletePageState();
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Lottie.asset("assets/lottie/completed.json"),
            Text("You have paid \$${widget.invoice.total}"),

          ],
        ),
      ),
    );
  }
}
