import 'package:awesome_card/credit_card.dart';
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart' as card;
import 'package:flutter_masked_text/flutter_masked_text.dart';

class CardPage extends StatefulWidget {
  String gateRecordId;
  int fee;

  CardPage({
    key,
    gateRecordId,
    fee,
  })  : this.gateRecordId = gateRecordId,
        this.fee = fee,
        super(key: key);

  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  String carPlateNum = "PK12345";
  String parkingLocation = "LG3-12";
  int parkingDuation = 130;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  // String cardNumber = "";
  // String cardHolderName = "";
  // String expiryDate = "";
  String cvv = "";
  bool showBack = false;

  FocusNode _focusNode;

  MaskedTextController _expiryTextController =
      MaskedTextController(mask: '00/00');

  @override
  void initState() {
    super.initState();
    _focusNode = new FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Credit Card'),
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: CreditCard(
                cardNumber: cardNumber,
                cardExpiry: expiryDate,
                cardHolderName: cardHolderName,
                cvv: cvv,
                bankName: "",
                showBackSide: showBack,
                frontBackground: card.CardBackgrounds.black,
                backBackground: card.CardBackgrounds.white,
                showShadow: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: "Card Number"),
                    maxLength: 19,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        cardNumber = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: TextFormField(
                      decoration:
                          InputDecoration(labelText: "Card Holder Name"),
                      onChanged: (value) {
                        setState(() {
                          cardHolderName = value;
                        });
                      },
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: TextFormField(
                            controller: this._expiryTextController,
                            decoration: InputDecoration(labelText: "Expiry Date"),
                            maxLength: 5,
                            onChanged: (value) {
                              setState(() {
                                expiryDate = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: "CVV"),
                            maxLength: 3,
                            onChanged: (value) {
                              setState(() {
                                cvv = value;
                              });
                            },
                            focusNode: _focusNode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Pay Now with Credit Card"),
                    Icon(Icons.navigate_next)
                  ],
                ),
                onPressed: () => {},
                splashColor: Colors.redAccent,
              ),
            )
          ],
        ),
      ),
    );
  }
}
