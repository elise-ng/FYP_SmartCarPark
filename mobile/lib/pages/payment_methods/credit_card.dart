import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class CardPage extends StatefulWidget {
  CardPage({
    key,
  }) : super(key: key);

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

    var controller = new MaskedTextController(mask: '00/00');


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
              },
          ),
        ),
        body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            CreditCard(
              cardNumber: cardNumber,
              cardExpiry: expiryDate,
              cardHolderName: cardHolderName,
              cvv: cvv,
              bankName: "",
              showBackSide: showBack,
              frontBackground: CardBackgrounds.black,
              backBackground: CardBackgrounds.white,
              showShadow: true,
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "Card Number"),
                    maxLength: 19,
                    onChanged: (value) {
                      setState(() {
                        cardNumber = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(hintText: "Card Expiry"),
                    maxLength: 5,
                    onChanged: (value) {
                      setState(() {
                        expiryDate = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "Card Holder Name"),
                    onChanged: (value) {
                      setState(() {
                        cardHolderName = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: TextFormField(
                    decoration: InputDecoration(hintText: "CVV"),
                    maxLength: 3,
                    onChanged: (value) {
                      setState(() {
                        cvv = value;
                      });
                    },
                    focusNode: _focusNode,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: RaisedButton( 
                        color: Theme.of(context).primaryColor, 
                        textColor: Colors.white, 
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Pay Now with Credit Card"),
                        Icon(Icons.navigate_next)                          
                      ], ), 
                        onPressed: () => {}, 
                        splashColor: Colors.redAccent,
                      ),
                ),
              ],
            )
          ],
        ),
      ),
      ),
    );
  }
}
