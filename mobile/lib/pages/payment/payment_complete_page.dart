import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PaymentCompletePage extends StatefulWidget {
  final double amount;

  PaymentCompletePage({
    this.amount,
  });

  @override
  _PaymentCompletePageState createState() => _PaymentCompletePageState();
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {
  void _pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: this._pop,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Lottie.asset(
                    "assets/lottie/completed.json",
                    repeat: false,
                    width: 200,
                  ),
                  Text(
                    "You have paid \$${widget.amount}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 36),
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
                      Text("Return"),
                    ],
                  ),
                  onPressed: this._pop,
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
