import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_car_park_app/widgets/signin_widget.dart';

class KioskPage extends StatefulWidget {
  KioskPage({
    key,
  }) : super(key: key);

  @override
  _KioskPageState createState() => _KioskPageState();
}

enum GateMode {
  entry,
  exit
}

enum GateFlowState {
  scanning,
  scanned,
  submitting,
  submitted
}

class _KioskPageState extends State<KioskPage> {

  bool _isSignedIn = FirebaseAuth.instance.currentUser() != null;

  GateMode _gateMode = GateMode.entry;
  GateFlowState _gateFlowState = GateFlowState.submitted;

  DocumentSnapshot _gateRecord;
  StreamSubscription<QuerySnapshot> _gateRecordSubscription;

  TextEditingController _vehicleIdTextEditingController = TextEditingController();
  TextEditingController _phoneNumberTextEditingController = TextEditingController();

  FocusNode _vehicleIdFocus = FocusNode();
  FocusNode _phoneNumberFocus = FocusNode();

  void onScanning() {
    setState(() {
      _gateFlowState = GateFlowState.scanning;
    });
    _gateRecordSubscription = Firestore.instance
      .collection('gateRecords')
      .where('entryGate', isEqualTo: 'southEntry')
      .where('entryConfirmTime', isNull: true)
      // .orderBy('entryScanTime', descending: false)
      .snapshots()
      .listen(
      (snapshot) {
        debugPrint(snapshot.documentChanges.length.toString());
        _gateRecord = snapshot.documentChanges.where((change) => change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified).map((change) => change.document).toList().first;
        if (_gateRecord != null) onScanned();
      },
      onError: (e) {
        debugPrint(e.toString());
      },
      onDone: () {
        debugPrint('onDone');
      });
  }

  void onScanned() {
    setState(() {
      _gateFlowState = GateFlowState.scanned;
      _vehicleIdTextEditingController.text = _gateRecord.data['vehicleId'];
      // TODO: read previous phone number
      _phoneNumberTextEditingController.text = '';
    });
    _gateRecordSubscription.cancel();
  }

  void submit() async {
    // TODO: form validation
    setState(() {
      _gateFlowState = GateFlowState.submitting;
    });
    try {
      await Firestore.instance
      .collection('gateRecords')
      .document(_gateRecord.documentID)
      .updateData(<String, dynamic>{
        'vehicleId': _vehicleIdTextEditingController.text,
        'phoneNumber': '+852' + _phoneNumberTextEditingController.text,
        'entryConfirmTime': Timestamp.fromDate(DateTime.now()),
      });
      onSubmitted();
    } catch (e) {
      debugPrint(e);
      // TODO: display error on ui
    }
  }

  void onSubmitted() {
    setState(() {
      _gateFlowState = GateFlowState.submitted;
    });
    Future.delayed(Duration(seconds: 3), () => onScanning());
  }

  @override
  void initState() {
    super.initState();
    onScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _isSignedIn ? null : SigninWidget(completion: () {
        setState(() {
          this._isSignedIn = FirebaseAuth.instance.currentUser() != null;
        });
      }),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                  color: Theme.of(context).splashColor,
                  // JOKE: cindy photo background
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  //     image: NetworkImage('https://www.cse.ust.hk/admin/people/faculty/photos/lixin.jpg'),
                  //     fit: BoxFit.cover,
                  //   )
                  // ),
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Lot Availability',
                            style: Theme.of(context).textTheme.display1,
                          ),
                        ),
                        // TODO: read real data
                        Table(
                          children: <TableRow>[
                            TableRow(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'LG1',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    '7',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]
                            ),TableRow(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'LG3',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    '21',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]
                            ),TableRow(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'LG4',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    '8',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]
                            ),TableRow(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'LG5',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    '31',
                                    style: Theme.of(context).textTheme.display2,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                )
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Welcome to Smart Car Park',
                            style: Theme.of(context).textTheme.display2,
                          ),
                        ),
                        _gateFlowState == GateFlowState.scanning
                        ? Expanded(
                          flex: 9,
                          child: Row(
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Padding(padding: EdgeInsets.only(left: 16.0)),
                              Text(
                                'Scanning License Plate...',
                                style: Theme.of(context).textTheme.display1,
                              )
                            ],
                          )
                        )
                        : Container(),
                        _gateFlowState == GateFlowState.scanned
                        ? Expanded(
                          flex: 9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Please confirm your information:',
                                style: Theme.of(context).textTheme.display1,
                              ),
                              Padding(padding: EdgeInsets.only(top: 32.0)),
                              TextField(
                                focusNode: _vehicleIdFocus,
                                controller: _vehicleIdTextEditingController,
                                decoration: InputDecoration(labelText: "License Plate"),
                                style: Theme.of(context).textTheme.display1,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (value) {
                                  _vehicleIdFocus.unfocus();
                                  FocusScope.of(context).requestFocus(_phoneNumberFocus);
                                },
                              ),
                              TextField(
                                focusNode: _phoneNumberFocus,
                                controller: _phoneNumberTextEditingController,
                                decoration: InputDecoration(labelText: "Phone Number"),
                                style: Theme.of(context).textTheme.display1,
                                keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (value) {
                                  _phoneNumberFocus.unfocus();
                                  // TODO: submit form
                                },
                              ),
                              Padding(padding: EdgeInsets.only(top: 40.0)),
                              Container(
                                height: 80.0,
                                width: 240.0,
                                child: RaisedButton(
                                  child: Text(
                                    'Submit',
                                    style: Theme.of(context).textTheme.display1.copyWith(color: Colors.white),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () {
                                    // TODO: submit form
                                    submit();
                                  },
                                )
                              )
                            ],
                          )
                        )
                        : Container(),
                        _gateFlowState == GateFlowState.submitting
                        ? Expanded(
                          flex: 9,
                          child: Row(
                            children: <Widget>[
                              CircularProgressIndicator(),
                              Padding(padding: EdgeInsets.only(left: 16.0)),
                              Text(
                                'Submitting...',
                                style: Theme.of(context).textTheme.display1,
                              )
                            ],
                          )
                        )
                        : Container(),
                        _gateFlowState == GateFlowState.submitted
                        ? Expanded(
                          flex: 9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.check_circle,
                                size: 100.0,
                                color: Colors.green,
                              ),
                              Text(
                                'Registration Completed',
                                style: Theme.of(context).textTheme.display1,
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 80.0)
                              ),
                              Text(
                                'Check SMS for instruction to use our mobile app for payment and other services',
                                style: Theme.of(context).textTheme.display1,
                                textAlign: TextAlign.center,
                              )
                            ],
                          )
                        )
                        : Container()
                      ],
                    ),
                )
                
              ),
            ],
          )
        ),
      ),
    
      
      
      
    
    );
  }
}
