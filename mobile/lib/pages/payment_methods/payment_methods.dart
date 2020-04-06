import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  PaymentMethodPage({
    key,
  }) : super(key: key);

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        //key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Payment method'),
          leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
              onPressed: () {
                /*setState(() {
                  _source = null;
                  _paymentIntent = null;
                  _paymentMethod = null;
                  _paymentToken = null;
                });*/
              },
          ),
          ),
        body: ListView(
          padding: const EdgeInsets.all(60),
          children: <Widget>[
            RaisedButton(
              child: Text("Credit Card" ,style: TextStyle(fontSize: 16)),
              onPressed: () {
              },
            ),
            Divider(),
            RaisedButton(
              child: Text("Alipay",style: TextStyle(fontSize: 16)),
              onPressed: () {
              },
            ),
            RaisedButton(
              child: Text("WeChatpay",style: TextStyle(fontSize: 16)),
              onPressed: () {
              },
            ),
            Divider(),
            RaisedButton(
              child: Text("Pay in Security Center",style:TextStyle(fontSize: 16)),
              onPressed: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}
