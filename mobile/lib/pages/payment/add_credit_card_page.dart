import 'package:awesome_card/credit_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:awesome_card/awesome_card.dart' as card;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:smart_car_park_app/models/payment_method.dart';
import 'package:smart_car_park_app/pages/payment/payment_summary_page.dart';
import 'package:smart_car_park_app/widgets/progress_dialog.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
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
  String _cardNumber = "";
  String _cardExpDate = "";

  StripeCard _card = StripeCard();
  FocusNode _cvvFocusNode = FocusNode();

  bool _saveCardDetails = true;

  MaskTextInputFormatter _cardNumberTextFormatter = MaskTextInputFormatter(
      mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
  MaskTextInputFormatter _expiryTextFormatter =
      MaskTextInputFormatter(mask: '##/##', filter: {"#": RegExp(r'[0-9]')});
  MaskTextInputFormatter _cvvTextFormatter =
      MaskTextInputFormatter(mask: '####', filter: {"#": RegExp(r'[0-9]')});

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

  void _payWithCard() async {
    ProgressDialog.show(context);
    var rawPaymentMethod =
        await StripeApi.instance.createPaymentMethodFromCard(this._card);
    if (this._saveCardDetails) {
      rawPaymentMethod = await CustomerSession.instance
          .attachPaymentMethod(rawPaymentMethod['id']);
    }
    PaymentMethod paymentMethod = PaymentMethod.fromJson(rawPaymentMethod);
    ProgressDialog.hide(context);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentSummaryPage(
          method: paymentMethod,
        ),
      ),
    );
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
                    cardNumber: this._cardNumber,
                    cardExpiry: this._cardExpDate,
                    cardHolderName: this._card.name ?? "",
                    cvv: this._card.cvc ?? "",
                    showBackSide: this._cvvFocusNode.hasFocus,
                    frontBackground: card.CardBackgrounds.black,
                    backBackground: card.CardBackgrounds.white,
                    frontTextColor: Colors.white,
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
                          decoration: InputDecoration(
                              labelText: "Card Number", counterText: ""),
                          inputFormatters: [this._cardNumberTextFormatter],
                          maxLength: 19,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              this._cardNumber = value;
                              this._card.number = value.replaceAll(" ", "");
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
                                inputFormatters: [this._expiryTextFormatter],
                                decoration: InputDecoration(
                                  labelText: "Expiry Date",
                                  counterText: "",
                                  hintText: "MM/YY",
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 5,
                                onChanged: (value) {
                                  setState(() {
                                    this._cardExpDate = value;
                                    List<String> splitExp = value.split("/");
                                    if (splitExp.length >= 2) {
                                      this._card.expMonth =
                                          int.parse(splitExp[0]);
                                      this._card.expYear =
                                          int.parse(splitExp[1]) + 2000;
                                    }
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
                                inputFormatters: [this._cvvTextFormatter],
                                decoration: InputDecoration(
                                  labelText: "CVV",
                                  counterText: "",
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 4,
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
