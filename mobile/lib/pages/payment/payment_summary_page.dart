import 'package:flutter/material.dart';
import 'package:smart_car_park_app/models/payment_method.dart';

class PaymentSummaryPage extends StatefulWidget {
  final PaymentMethod method;

  PaymentSummaryPage({
    this.method,
  });

  @override
  _PaymentSummaryPageState createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
