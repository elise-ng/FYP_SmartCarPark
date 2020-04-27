import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PayInPersonPage extends StatefulWidget {
  String gateRecordId;
  PayInPersonPage({
    key,
    gateRecordId,
  }) : this.gateRecordId = gateRecordId, super(key: key);

  @override
  _PayInPersonPageState createState() => _PayInPersonPageState();
}

class _PayInPersonPageState extends State<PayInPersonPage> {
  @override
  Widget build(BuildContext context) {
    String gateRecordId = widget.gateRecordId;
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Payments'),
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
              },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(child: QrImage(
              data: gateRecordId,
              version: QrVersions.auto,
              size: 300,
              gapless: false,
            ),
            ),
            Text("Please pay cash in Security Center", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
