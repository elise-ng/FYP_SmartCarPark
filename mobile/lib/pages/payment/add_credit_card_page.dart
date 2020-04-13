import 'package:awesome_card/credit_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart' as card;
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';

class AddCreditCardPage extends StatefulWidget {
  final String gateRecordId;

  AddCreditCardPage({
    key,
    this.gateRecordId,
  }) : super(key: key);

  @override
  _AddCreditCardPageState createState() => _AddCreditCardPageState();
}

class _AddCreditCardPageState extends State<AddCreditCardPage> {
  StripeCard _card = StripeCard(number: "", cvc: "");
  FocusNode _cvvFocusNode = FocusNode();

  bool _saveCardDetails = true;

  MaskedTextController _cardNumberTextController =
      MaskedTextController(mask: '0000 0000 0000 0000');

  MaskedTextController _expiryTextController =
      MaskedTextController(mask: '00/00');

  @override
  void initState() {
    super.initState();
    _cvvFocusNode.addListener(() {
      setState(() {
        /// Update card show back state
      });
    });
  }

  @override
  void dispose() {
    _cvvFocusNode.dispose();
    super.dispose();
  }

  bool _isCardValid() {
    return this._card.validateCard();
  }

  void _payWithCard() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Card'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: CreditCard(
                    cardNumber: this._card.number,
                    cardExpiry: null,
                    cardHolderName: this._card.name,
                    cvv: this._card.cvc,
                    showBackSide: this._cvvFocusNode.hasFocus,
                    frontBackground: card.CardBackgrounds.white,
                    backBackground: card.CardBackgrounds.white,
                    frontTextColor: Colors.black,
                    showShadow: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "Card Number", counterText: ""),
                          controller: this._cardNumberTextController,
                          maxLength: 19,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              this._card.number = value;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          decoration:
                              InputDecoration(labelText: "Card Holder Name"),
                          onChanged: (value) {
                            setState(() {
                              this._card.name = value;
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
                                decoration:
                                    InputDecoration(labelText: "Expiry Date", counterText: ""),
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                onChanged: (value) {
                                  setState(() {
//                                    expiryDate = value;
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
                                focusNode: this._cvvFocusNode,
                                decoration: InputDecoration(labelText: "CVV", counterText: ""),
                                keyboardType: TextInputType.number,
                                maxLength: 3,
                                onChanged: (value) {
                                  setState(() {
                                    this._card.cvc = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                  title: Text("Save card details"),
                  trailing: CupertinoSwitch(
                    value: this._saveCardDetails,
                    onChanged: (value) {
                      setState(() {
                        this._saveCardDetails = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
                    onPressed: this._isCardValid() ? this._payWithCard : null,
                    splashColor: Colors.redAccent,
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
