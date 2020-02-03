import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({
    key,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Shut up and give me your money"),
    );
  }
}
