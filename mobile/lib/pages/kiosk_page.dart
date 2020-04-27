import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_car_park_app/models/car_park_floor.dart';
import 'package:smart_car_park_app/models/car_park_space.dart';
import 'package:smart_car_park_app/models/gate_record.dart';
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
  String _iotDeviceId = 'southEntry';

  GateRecord _gateRecord;
  StreamSubscription<QuerySnapshot> _gateRecordSubscription;

  TextEditingController _vehicleIdTextEditingController = TextEditingController();
  TextEditingController _phoneNumberTextEditingController = TextEditingController();

  FocusNode _vehicleIdFocus = FocusNode();
  FocusNode _phoneNumberFocus = FocusNode();

  Map<String, int> _floorStatus = {};
  Map<String, String> _floorName = {};

  String _errorMessage = '';

  void onScanning() {
    setState(() {
      _gateFlowState = GateFlowState.scanning;
    });
    switch (_gateMode) {
      case GateMode.entry:
        _gateRecordSubscription = Firestore.instance
            .collection('gateRecords')
            .where('entryGate', isEqualTo: _iotDeviceId)
            .where('entryConfirmTime', isNull: true)
            .orderBy('entryScanTime', descending: false)
            .limit(1)
            .snapshots()
            .listen(
                (snapshot) {
              final gateRecords = snapshot.documents
                  .map((doc) => GateRecord.fromDocumentSnapshot(doc))
                  .toList();
              if (gateRecords.isNotEmpty) {
                _gateRecord = gateRecords.first;
                onScanned();
              }
            },
            onError: (e) {
              debugPrint(e.toString());
            },
            onDone: () {
              debugPrint('onDone');
            });
        break;
      case GateMode.exit:
        _gateRecordSubscription = Firestore.instance
            .collection('gateRecords')
            .where('exitGate', isEqualTo: _iotDeviceId)
            .where('exitConfirmTime', isNull: true)
            .orderBy('exitScanTime', descending: false)
            .limit(1)
            .snapshots()
            .listen(
                (snapshot) {
              final gateRecords = snapshot.documents
                  .map((doc) => GateRecord.fromDocumentSnapshot(doc))
                  .toList();
              if (gateRecords.isNotEmpty) {
                _gateRecord = gateRecords.first;
                onScanned();
              }
            },
            onError: (e) {
              debugPrint(e.toString());
            },
            onDone: () {
              debugPrint('onDone');
            });
        break;
    }
  }

  Future<String> getLastPhoneNumber(String vehicleId) async {
    final response = await Firestore.instance
    .collection('gateRecords')
    .where('vehicleId', isEqualTo: vehicleId)
    .where('phoneNumber', isGreaterThan: '') // not null and not empty string
    .orderBy('phoneNumber') // required by firestore, can't orderBy another field after comparison
    .orderBy('entryScanTime', descending: true)
    .limit(1)
    .getDocuments();
    return response.documents.isNotEmpty ? GateRecord.fromDocumentSnapshot(response.documents.first).phoneNumber.replaceAll('+852', '') : null;
  }

  void onScanned() async {
    switch (_gateMode) {
      case GateMode.entry:
        final lastPhoneNumber = await getLastPhoneNumber(_gateRecord.vehicleId);
        setState(() {
          _gateFlowState = GateFlowState.scanned;
          _errorMessage = '';
          _vehicleIdTextEditingController.text = _gateRecord.vehicleId;
          _phoneNumberTextEditingController.text = lastPhoneNumber ?? '';
        });
        break;
      case GateMode.exit:
      // TODO: Exit mode ui
        break;
    }
    _gateRecordSubscription.cancel();
  }

  void submit() async {
    final vehicleId = _vehicleIdTextEditingController.text;
    final phoneNumber = _phoneNumberTextEditingController.text;

    if (vehicleId.isEmpty) {
      setState(() {
        _errorMessage = 'License Plate is empty';
      });
      return;
    }

    if (phoneNumber.isEmpty || phoneNumber.length != 8 || int.tryParse(phoneNumber) == null) {
      setState(() {
        _errorMessage = 'Phone Number is empty or invalid';
      });
      return;
    }

    setState(() {
      _gateFlowState = GateFlowState.submitting;
    });
    try {
      await Firestore.instance
      .collection('gateRecords')
      .document(_gateRecord.id)
      .updateData(<String, dynamic>{
        'vehicleId': vehicleId.toUpperCase(),
        'phoneNumber': '+852' + phoneNumber,
        'entryConfirmTime': Timestamp.fromDate(DateTime.now()),
      });
      onSubmitted();
    } catch (e) {
      debugPrint(e);
      setState(() {
        _gateFlowState = GateFlowState.scanned;
        _errorMessage = e.toString();
      });
    }
  }

  void onSubmitted() {
    setState(() {
      _gateFlowState = GateFlowState.submitted;
    });
    Future.delayed(Duration(seconds: 5), () => onScanning());
  }

  void getFloorNames() async {
    Map<String, String> floorName = (await Firestore.instance
    .collection('carParkFloors')
    .getDocuments())
    .documents
    .map((doc) => CarParkFloor.fromDocument(doc))
    .map((floor) => {floor.id : floor.name})
    .reduce((val, elem) {
      val.keys.contains(elem.keys.first) ? val[elem.keys.first] += elem.values.first : val[elem.keys.first] = elem.values.first;
      return val;
    });
    setState(() {
      _floorName = floorName;
    });
  }

  @override
  void initState() {
    super.initState();
    onScanning();
    getFloorNames();
    Firestore.instance
    .collection('iotStates')
    .snapshots()
    .listen((snapshot) {
      setState(() {
        _floorStatus = snapshot.documents
        .map((doc) => CarParkSpace.fromDocument(doc))
        .map((space) => {space.floorId : space.state == ParkingState.Vacant ? 1 : 0})
        .reduce((val, elem) {
          val.keys.contains(elem.keys.first) ? val[elem.keys.first] += elem.values.first : val[elem.keys.first] = elem.values.first;
          return val;
        });
      });
    });
  }

  Widget availabilityUI() {
    return Padding(
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
          _floorStatus.keys.isNotEmpty
              ? Table(
              children: _floorStatus.keys.map((key) => TableRow(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _floorName.keys.contains(key) ? _floorName[key] : key ?? '',
                        style: Theme.of(context).textTheme.display2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _floorStatus[key].toString(),
                        style: Theme.of(context).textTheme.display2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]
              )).toList()
          )
              : CircularProgressIndicator()
        ],
      ),
    );
  }

  Widget scanningUI() {
    return Expanded(
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
    );
  }

  Widget entryScannedUI() {
    return Expanded(
        flex: 9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Please confirm your information:',
              style: Theme.of(context).textTheme.display1,
            ),
            Padding(padding: EdgeInsets.only(top: 16.0)),
            _errorMessage.isNotEmpty
                ? Text(
              _errorMessage,
              style: Theme.of(context).textTheme.headline.copyWith(color: Colors.red),
            )
                : Container(),
            Padding(padding: EdgeInsets.only(top: 16.0)),
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
                    submit();
                  },
                )
            )
          ],
        )
    );
  }

  Widget submittingUI() {
    return Expanded(
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
    );
  }

  Widget entrySubmittedUI() {
    return Expanded(
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
    );
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
                  child: _gateMode == GateMode.entry
                    ? availabilityUI()
                    : Container()
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
                        ? scanningUI()
                        : Container(),
                        _gateFlowState == GateFlowState.scanned
                        ? _gateMode == GateMode.entry ? entryScannedUI() : Container()
                        : Container(),
                        _gateFlowState == GateFlowState.submitting
                        ? submittingUI()
                        : Container(),
                        _gateFlowState == GateFlowState.submitted
                        ? _gateMode == GateMode.entry ? entrySubmittedUI() : Container()
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
