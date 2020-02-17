import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SigninWidget extends StatefulWidget {

  SigninWidget({
    Key key
  }) : super(key: key);

  @override
  _SigninWidgetState createState() => new _SigninWidgetState();
}


enum SigninState {
  codeNotSent,
  codeSending,
  codeSent,
}

class _SigninWidgetState extends State<SigninWidget> {

  final _firebaseAuth = FirebaseAuth.instance;

  SigninState _signinState = SigninState.codeNotSent;
  String _errorMessage = '';

  TextEditingController _phoneNumberTextEditingController = TextEditingController();
  TextEditingController _smsCodeTextEditingController = TextEditingController();

  // id of verification session
  String _verificationId;
  int _forceResendingToken;

  /// Send SMS code and try to auto-retrieve for instant sign in
  void sendVerificationCode(String phoneNumber) {
    setState(() {
      _signinState = SigninState.codeNotSent;
    });
    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+852'+phoneNumber,
      timeout: Duration(seconds: 30),
      forceResendingToken: _forceResendingToken,
      verificationCompleted: (credential) async {
        try {
          final result = await _firebaseAuth.signInWithCredential(credential);
          if (result.user != null) {
            // TODO: success, dismiss widget

          } else {
            // TODO: show error
            setState(() {
              _errorMessage = 'Sign in failed.';
            });
          }
        } catch (e) {
          debugPrint(e.toString());
          setState(() {
            _errorMessage = 'Error: ${e.toString()}';
          });
        }
      },
      verificationFailed: (e) {
        debugPrint(e.toString());
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
      },
      codeSent: (verificationId, [forceResendingToken]) {
        _verificationId = verificationId;
        _forceResendingToken = forceResendingToken;
        setState(() {
          _signinState = SigninState.codeSent;
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        // Do nothing, wait for user input
      }
    );
  }

  /// Manually submit SMS code, for when auto-retrieve fails
  void signIn(String smsCode) {
    final credential = PhoneAuthProvider.getCredential(verificationId: _verificationId, smsCode: smsCode);
    _firebaseAuth.signInWithCredential(credential);
  }

  /// Request resend of SMS code
  void resendToken(String phoneNumber) {
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [ BoxShadow(blurRadius: 4.0, color: Colors.grey, spreadRadius: 2.0) ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,              
              children: <Widget>[
                Text(
                  "Welcome to Smart Car Park",
                  style: Theme.of(context).textTheme.subhead
                ),
                Padding(padding: EdgeInsets.only(top: 4.0)),
                Text(
                  "Sign in to access more features.",
                  style: Theme.of(context).textTheme.subtitle,
                ),
                Padding(padding: EdgeInsets.only(top: 4.0)),
                _errorMessage.isNotEmpty
                ? Text(
                  _errorMessage,
                  style: Theme.of(context).textTheme.subtitle.copyWith(color: Colors.red),
                )
                : Container()
              ],
            ),
          ),
          // Padding(padding: EdgeInsets.only(top: 4.0)),
          Container(
            width: double.infinity,
            child: TextFormField(
              controller: _phoneNumberTextEditingController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 7,
                child: TextFormField(
                  controller: _smsCodeTextEditingController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(labelText: "Verification Code"),
                )
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: OutlineButton(
                    child: () {
                      switch (_signinState) {
                        case SigninState.codeNotSent:
                          return Text('Get Code');
                        case SigninState.codeSending:
                          return CircularProgressIndicator();
                        case SigninState.codeSent:
                          return Text('Code Sent');
                        default:
                          return Container();
                      }
                    }(),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    onPressed: _signinState == SigninState.codeNotSent
                    ? () {
                      sendVerificationCode(_phoneNumberTextEditingController.text);
                    }
                    : null
                  )
                )
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 24.0)),
          Container(
            width: double.infinity,
            height: 40.0,
            child: RaisedButton(
              child: Text("Login"),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: _signinState == SigninState.codeSent
              ? () {
                signIn(_smsCodeTextEditingController.text);
              }
              : null
            ),
          )
        ],
      )
    );
  }
}