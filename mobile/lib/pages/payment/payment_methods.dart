import 'package:flutter/material.dart';
import 'package:smart_car_park_app/pages/payment/pay_inperson.dart';
import 'package:smart_car_park_app/pages/payment/credit_card.dart';

class PaymentMethodPage extends StatefulWidget {
  String gateRecordId;
  int fee; 
  PaymentMethodPage({
    key,
    gateRecordId,
    fee,
  }) : this.gateRecordId = gateRecordId, this.fee = fee, super(key: key); 
  
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
                Navigator.pop(context);
              },
          ),
          ),
        body: ListView(
          padding: const EdgeInsets.all(60),
          children: <Widget>[
            RaisedButton(
              child: Text("Credit Card" ,style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CardPage(gateRecordId: widget.gateRecordId, fee:widget.fee)),
                  );
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
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PayInPersonPage(gateRecordId: widget.gateRecordId)),
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}
