import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car_park_app/global_variables.dart';
import 'package:smart_car_park_app/utils/user_utils.dart';

class SigninWidget extends StatefulWidget {

  /// Completion Handler. Returns boolean indicating sign in result
  Function() completion;

  SigninWidget({
    this.completion,
    Key key
  }) : super(key: key);

  @override
  _SigninWidgetState createState() => new _SigninWidgetState();
}


enum SmsCodeState {
  codeNotSent,
  codeSending,
  codeSent
}

enum SigninState {
  pending,
  inProgress,
  success
}

class _SigninWidgetState extends State<SigninWidget> {

  final _firebaseAuth = FirebaseAuth.instance;

  SmsCodeState _smsCodeState = SmsCodeState.codeNotSent;
  SigninState _signinState = SigninState.pending;
  String _errorMessage = '';

  TextEditingController _phoneNumberTextEditingController = TextEditingController();
  TextEditingController _smsCodeTextEditingController = TextEditingController();

  FocusNode _phoneNumberFocus = FocusNode();
  FocusNode _smsCodeFocus = FocusNode();

  // id of verification session
  String _verificationId;
  int _forceResendingToken;

  @override
  void initState() {
    super.initState();
    this._signinState = userRecord.isAuthenticated() ? SigninState.pending : SigninState.success;
  }

  /// Send SMS code and try to auto-retrieve for instant sign in
  void sendVerificationCode(String phoneNumber) {
    setState(() {
      _errorMessage = '';
      _smsCodeState = SmsCodeState.codeNotSent;
    });
    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+852'+phoneNumber,
      timeout: Duration(seconds: 30),
      forceResendingToken: _forceResendingToken,
      verificationCompleted: (credential) async {
        try {
          final result = await _firebaseAuth.signInWithCredential(credential);
          if (result.user != null) {
            userRecord.update(await UserUtils.getUserRecordDocument(result.user.uid, source: Source.server));
            setState(() {
              _signinState = SigninState.success;
            });
            Future.delayed(Duration(seconds: 1), widget.completion());
          } else {
            setState(() {
              _errorMessage = 'Sign in failed.';
            });
          }
        } on PlatformException catch (e) {
          debugPrint(e.toString());
          setState(() {
            _errorMessage = 'Error: ${e.message}';
          });
        } catch (e) {
          debugPrint(e.toString());
          setState(() {
            _errorMessage = 'Error: ${e.toString()}';
          });
        }
      },
      verificationFailed: (e) {
        debugPrint(e.message);
        setState(() {
          _errorMessage = 'Error: ${e.message}';
        });
      },
      codeSent: (verificationId, [forceResendingToken]) {
        _verificationId = verificationId;
        _forceResendingToken = forceResendingToken;
        setState(() {
          _smsCodeState = SmsCodeState.codeSent;
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
        // Do nothing, wait for user input
      }
    );
  }

  /// Manually submit SMS code, for when auto-retrieve fails
  void signIn(String smsCode) async {
    setState(() {
      _errorMessage = '';
      _signinState = SigninState.inProgress;
    });
    try {
      final credential = PhoneAuthProvider.getCredential(verificationId: _verificationId, smsCode: smsCode);
      final _result = await _firebaseAuth.signInWithCredential(credential);
      if (_result.user != null) {
        setState(() {
          _signinState = SigninState.success;
        });
        Future.delayed(Duration(seconds: 1), widget.completion());
      } else {
        setState(() {
          _errorMessage = 'Sign in failed.';
          _signinState = SigninState.pending;
        });
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      setState(() {
        _errorMessage = 'Error: ${e.message}';
        _signinState = SigninState.pending;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _signinState = SigninState.pending;
      });
    }
  }

  // TODO: allow resend sms code after timeout

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      padding: EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [ BoxShadow(blurRadius: 4.0, color: Colors.grey, spreadRadius: 2.0) ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _signinState == SigninState.success
        // Success Prompt
        ? <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 24.0)),
              Icon(
                Icons.check_circle,
                size: 40.0,
                color: Colors.green,
              ),
              Text(
                'Sign in success',
                style: Theme.of(context).textTheme.title,
              ),
              Padding(padding: EdgeInsets.only(bottom: 24.0)),
            ],
          )
        ]
        // Sign in form
        : <Widget>[
          Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,              
              children: <Widget>[
                Text(
                  "Welcome to Smart Car Park",
                  style: Theme.of(context).textTheme.headline
                ),
                Padding(padding: EdgeInsets.only(top: 4.0)),
                Text(
                  "Sign in to access more features.",
                  style: Theme.of(context).textTheme.subhead,
                ),
                Padding(padding: EdgeInsets.only(top: 4.0)),
                _errorMessage.isNotEmpty
                ? Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    _errorMessage,
                    style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.red),
                  )
                )
                : Container()
              ],
            ),
          ),
          Container(
            width: double.infinity,
            child: TextFormField(
              controller: _phoneNumberTextEditingController,
              focusNode: _phoneNumberFocus,
              keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
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
                  focusNode: _smsCodeFocus,
                  keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                  decoration: InputDecoration(labelText: "Verification Code"),
                )
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: RaisedButton(
                    child: () {
                      switch (_smsCodeState) {
                        case SmsCodeState.codeNotSent:
                          return Text('Get Code');
                        case SmsCodeState.codeSending:
                          return CircularProgressIndicator();
                        case SmsCodeState.codeSent:
                          return Text('Code Sent');
                        default:
                          return Container();
                      }
                    }(),
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    onPressed: _smsCodeState == SmsCodeState.codeNotSent
                    ? () {
                      sendVerificationCode(_phoneNumberTextEditingController.text);
                      _phoneNumberFocus.unfocus();
                      FocusScope.of(context).requestFocus(_smsCodeFocus);
                    }
                    : null
                  )
                )
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(top: 24.0)),
          _signinState == SigninState.inProgress
          ? CircularProgressIndicator()
          : Container(
            width: double.infinity,
            height: 40.0,
            child: RaisedButton(
              child: Text("Login"),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: _smsCodeState == SmsCodeState.codeSent
              ? () {
                signIn(_smsCodeTextEditingController.text);
                _smsCodeFocus.unfocus();
              }
              : null
            ),
          )
        ],
      )
    );
  }
}