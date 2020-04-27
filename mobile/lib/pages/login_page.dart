import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car_park_app/global_variables.dart';
import 'package:smart_car_park_app/utils/user_utils.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum SmsCodeState { codeNotSent, codeSending, codeSent }

enum SigninState { pending, inProgress, success }

class _LoginPageState extends State<LoginPage> {
  final _firebaseAuth = FirebaseAuth.instance;

  SmsCodeState _smsCodeState = SmsCodeState.codeNotSent;
  SigninState _signInState = SigninState.pending;
  String _errorMessage = '';

  TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  TextEditingController _smsCodeTextEditingController = TextEditingController();

  FocusNode _phoneNumberFocus = FocusNode();
  FocusNode _smsCodeFocus = FocusNode();

  // id of verification session
  String _verificationId;
  int _forceResendingToken;

  @override
  void initState() {
    super.initState();
    this._signInState = userRecord.isAuthenticated()
        ? SigninState.success
        : SigninState.pending;
  }

  /// Send SMS code and try to auto-retrieve for instant sign in
  void sendVerificationCode(String phoneNumber) {
    setState(() {
      _errorMessage = '';
      _smsCodeState = SmsCodeState.codeNotSent;
    });
    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: '+852' + phoneNumber,
        timeout: Duration(seconds: 30),
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (credential) async {
          try {
            final result = await _firebaseAuth.signInWithCredential(credential);
            if (result.user != null) {
              userRecord.update(await UserUtils.getUserRecordDocument(
                result.user.uid,
                source: Source.server,
              ));
              // TODO: success, dismiss widget
              setState(() {
                _signInState = SigninState.success;
              });
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
        });
  }

  /// Manually submit SMS code, for when auto-retrieve fails
  void signIn(String smsCode) async {
    setState(() {
      _errorMessage = '';
      _signInState = SigninState.inProgress;
    });
    try {
      final credential = PhoneAuthProvider.getCredential(
          verificationId: _verificationId, smsCode: smsCode);
      final _result = await _firebaseAuth.signInWithCredential(credential);
      if (_result.user != null) {
        userRecord.update(await UserUtils.getUserRecordDocument(
          _result.user.uid,
          source: Source.server,
        ));
        setState(() {
          _signInState = SigninState.success;
        });
      } else {
        setState(() {
          _errorMessage = 'Sign in failed.';
          _signInState = SigninState.pending;
        });
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      setState(() {
        _errorMessage = 'Error: ${e.message}';
        _signInState = SigninState.pending;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _signInState = SigninState.pending;
      });
    }
  }

  // TODO: allow resend sms code after timeout

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(24.0),
          child: _signInState == SigninState.success
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 40.0,
                          color: Colors.green,
                        ),
                        Text(
                          'Sign in success',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Welcome to Smart Car Park",
                              style: Theme.of(context).textTheme.headline),
                          Padding(padding: EdgeInsets.only(top: 4.0)),
                          Text(
                            "Sign in to access more features.",
                            style: Theme.of(context).textTheme.subhead,
                          ),
                          Padding(padding: EdgeInsets.only(top: 4.0)),
                          _errorMessage.isNotEmpty
                              ? Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Text(
                                    _errorMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: Colors.red),
                                  ))
                              : Container()
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _phoneNumberTextEditingController,
                        focusNode: _phoneNumberFocus,
                        keyboardType: TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false,
                        ),
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                        ),
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
                            keyboardType: TextInputType.numberWithOptions(
                              signed: false,
                              decimal: false,
                            ),
                            decoration: InputDecoration(
                              labelText: "Verification Code",
                            ),
                          ),
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                onPressed:
                                    _smsCodeState == SmsCodeState.codeNotSent
                                        ? () {
                                            sendVerificationCode(
                                                _phoneNumberTextEditingController
                                                    .text);
                                            _phoneNumberFocus.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_smsCodeFocus);
                                          }
                                        : null),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 24.0),
                        child: _signInState == SigninState.inProgress
                            ? CircularProgressIndicator()
                            : Container(
                                width: double.infinity,
                                height: 48.0,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Text("Login"),
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                  onPressed: _smsCodeState ==
                                              SmsCodeState.codeSent &&
                                          _smsCodeTextEditingController
                                              .value.text.isNotEmpty
                                      ? () {
                                          signIn(_smsCodeTextEditingController
                                              .text);
                                          _smsCodeFocus.unfocus();
                                        }
                                      : null,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
