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

enum GateMode { entry, exit }

enum GateFlowState { scanning, scanned, submitting, submitted, contactStaff }

class _KioskPageState extends State<KioskPage> {
  bool _isSignedIn = FirebaseAuth.instance.currentUser() != null;

  GateMode _gateMode = GateMode.exit;
  String _iotDeviceId = 'demo4';
  final String _staffCode = '0000';

  GateFlowState _gateFlowState = GateFlowState.scanning;

  GateRecord _gateRecord;
  StreamSubscription<QuerySnapshot> _gateRecordSubscription;

  TextEditingController _vehicleIdTextEditingController =
      TextEditingController();
  TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  TextEditingController _staffCodeTextEditingController =
      TextEditingController();
  TextEditingController _iotDeviceIdTextEditingController =
      TextEditingController();
  TextEditingController _gateModeTextEditingController =
      TextEditingController();

  FocusNode _vehicleIdFocus = FocusNode();
  FocusNode _phoneNumberFocus = FocusNode();

  Map<String, int> _floorStatus = {};
  Map<String, String> _floorName = {};

  String _errorMessage = '';

  bool _exitLicensePlateNotRecognized = false;

  void onScanning() {
    setState(() {
      _gateFlowState = GateFlowState.scanning;
    });
    switch (_gateMode) {
      case GateMode.entry:
        _gateRecordSubscription?.cancel();
        _gateRecordSubscription = Firestore.instance
            .collection('gateRecords')
            .where('entryGate', isEqualTo: _iotDeviceId)
            .where('entryConfirmTime', isNull: true)
            // Do not use orderBy otherwise live response will not work
            .snapshots()
            .listen((snapshot) {
          final gateRecords = snapshot.documents
              .map((doc) => GateRecord.fromDocumentSnapshot(doc))
              .toList();
          gateRecords
              .sort((a, b) => -1 * a.entryScanTime.compareTo(b.entryScanTime));
          if (gateRecords.isNotEmpty) {
            _gateRecord = gateRecords.first;
            onScanned();
          }
        }, onError: (e) {
          debugPrint(e.toString());
        }, onDone: () {
          debugPrint('onDone');
        });
        break;
      case GateMode.exit:
        _gateRecordSubscription?.cancel();
        _gateRecordSubscription = Firestore.instance
            .collection('gateRecords')
            .where('exitGate', isEqualTo: _iotDeviceId)
            .where('exitConfirmTime', isNull: true)
            // Do not use orderBy otherwise live response will not work
            .snapshots()
            .listen((snapshot) {
          final gateRecords = snapshot.documents
              .map((doc) => GateRecord.fromDocumentSnapshot(doc))
              .toList();
          gateRecords.sort((a, b) => -1 * a.exitScanTime.compareTo(b.exitScanTime));
          if (gateRecords.isNotEmpty) {
            _gateRecord = gateRecords.first;
            onScanned();
          }
        }, onError: (e) {
          debugPrint(e.toString());
        }, onDone: () {
          debugPrint('onDone');
        });
        break;
    }
  }

  Future<String> getLastPhoneNumber(String vehicleId) async {
    final response = await Firestore.instance
        .collection('gateRecords')
        .where('vehicleId', isEqualTo: vehicleId)
        .where('phoneNumber',
            isGreaterThan: '') // not null and not empty string
        .orderBy(
            'phoneNumber') // required by firestore, can't orderBy another field after comparison
        .orderBy('entryScanTime', descending: true)
        .limit(1)
        .getDocuments();
    return response.documents.isNotEmpty
        ? GateRecord.fromDocumentSnapshot(response.documents.first)
            .phoneNumber
            .replaceAll('+852', '')
        : null;
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
        if (_gateRecord.entryScanTime == null) {
          // failed to recognize license plate
          setState(() {
            _gateFlowState = GateFlowState.scanned;
            _exitLicensePlateNotRecognized = true;
            _errorMessage =
                'Could not find entry record, please correct license plate:';
            _vehicleIdTextEditingController.text = _gateRecord.vehicleId;
          });
        } else {
          _exitLicensePlateNotRecognized = false;
          if (_gateRecord.paymentStatus == 'successful' &&
              _gateRecord.paymentTime != null) {
            final minutesAfterPayment =
                DateTime.now().difference(_gateRecord.paymentTime).inMinutes;
            if (minutesAfterPayment > 15) {
              // Paid but exceeded leave time
              onContactStaff(
                  'Duration after payment: ${minutesAfterPayment} minutes');
            } else {
              // Paid, proceed to success
              confirmExit();
            }
          } else {
            // not paid
            setState(() {
              _gateFlowState = GateFlowState.scanned;
              _exitLicensePlateNotRecognized = false;
              _errorMessage =
                  'Parking fee not settled. Please pay via mobile app or contact staff.';
              _vehicleIdTextEditingController.text = _gateRecord.vehicleId;
            });
          }
        }
        break;
    }
//    _gateRecordSubscription.cancel();
  }

  void entrySubmit() async {
    final vehicleId = _vehicleIdTextEditingController.text;
    final phoneNumber = _phoneNumberTextEditingController.text;

    if (vehicleId.isEmpty) {
      setState(() {
        _errorMessage = 'License Plate is empty';
      });
      return;
    }

    if (phoneNumber.isEmpty ||
        phoneNumber.length != 8 ||
        int.tryParse(phoneNumber) == null) {
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

  void exitSubmit() async {
    setState(() {
      _gateFlowState = GateFlowState.submitting;
    });
    if (_exitLicensePlateNotRecognized) {
      final vehicleId = _vehicleIdTextEditingController.text;
      final query = await Firestore.instance
          .collection('gateRecords')
          .where('vehicleId', isEqualTo: vehicleId)
          .where('exitConfirmTime', isNull: true)
          .orderBy('entryScanTime', descending: true)
          .limit(1)
          .getDocuments();
      if (query.documents.length > 0) {
        // true record found
        try {
          // remove current record
          await Firestore.instance
              .collection('gateRecords')
              .document(_gateRecord.id)
              .delete();
          // load true record and resume flow
          _gateRecord = GateRecord.fromDocumentSnapshot(query.documents.first);
          setState(() {
            _gateFlowState = GateFlowState.submitting;
          });
          onScanned();
        } catch (e) {
          debugPrint(e);
          setState(() {
            _gateFlowState = GateFlowState.scanned;
            _errorMessage = e.toString();
          });
        }
      } else {
        // record not found
        setState(() {
          _gateFlowState = GateFlowState.scanned;
          _errorMessage = 'Could not find entry record';
        });
      }
    } else {
      // refresh record and resume flow
      final doc = await Firestore.instance
          .collection('gateRecords')
          .document(_gateRecord.id)
          .get();
      _gateRecord = GateRecord.fromDocumentSnapshot(doc);
      onScanned();
    }
  }

  void confirmExit() async {
    try {
      setState(() {
        _gateFlowState = GateFlowState.submitting;
      });
      await Firestore.instance
          .collection('gateRecords')
          .document(_gateRecord.id)
          .updateData({'exitConfirmTime': Timestamp.fromDate(DateTime.now())});
      onSubmitted();
    } catch (e) {
      onContactStaff(e.toString());
    }
  }

  void onSubmitted() {
    setState(() {
      _gateFlowState = GateFlowState.submitted;
    });
    Future.delayed(Duration(seconds: 5), () => onScanning());
  }

  void onContactStaff(String message) {
    setState(() {
      _gateFlowState = GateFlowState.contactStaff;
      _errorMessage = message;
    });
  }

  void getFloorNames() async {
    Map<String, String> floorName =
        (await Firestore.instance.collection('carParkFloors').getDocuments())
            .documents
            .map((doc) => CarParkFloor.fromDocument(doc))
            .map((floor) => {floor.id: floor.name})
            .reduce((val, elem) {
      val.keys.contains(elem.keys.first)
          ? val[elem.keys.first] += elem.values.first
          : val[elem.keys.first] = elem.values.first;
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
    Firestore.instance.collection('iotStates').snapshots().listen((snapshot) {
      setState(() {
        _floorStatus = snapshot.documents
            .map((doc) => CarParkSpace.fromDocument(doc))
            .map((space) =>
                {space.floorId: space.state == ParkingState.Vacant ? 1 : 0})
            .reduce((val, elem) {
          val.keys.contains(elem.keys.first)
              ? val[elem.keys.first] += elem.values.first
              : val[elem.keys.first] = elem.values.first;
          return val;
        });
      });
    });
  }

  Widget staffOverrideButton() {
    return RaisedButton(
      child: Text('Staff Override'),
      onPressed: () {
        showDialog(
            context: context,
            child: AlertDialog(
              title: Text('Please enter staff code'),
              content: TextField(
                controller: _staffCodeTextEditingController,
                keyboardType: TextInputType.number,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Submit'),
                  onPressed: () {
                    if (_staffCodeTextEditingController.text == _staffCode) {
                      _staffCodeTextEditingController.text = '';
                      Navigator.of(context).pop();
                      confirmExit();
                    }
                  },
                )
              ],
            ));
      },
    );
  }

  void showStaffMenu() {
    _iotDeviceIdTextEditingController.text = _iotDeviceId;
    _gateModeTextEditingController.text = _gateMode.toString().split('.').last;
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Please enter staff code'),
          content: TextField(
            controller: _staffCodeTextEditingController,
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Submit'),
              onPressed: () {
                if (_staffCodeTextEditingController.text == _staffCode) {
                  _staffCodeTextEditingController.text = '';
                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text('Kiosk Config'),
                        content: Column(
                          children: <Widget>[
                            TextField(
                              controller: _iotDeviceIdTextEditingController,
                              decoration:
                                  InputDecoration(labelText: 'IoT Device ID'),
                            ),
                            TextField(
                              controller: _gateModeTextEditingController,
                              decoration: InputDecoration(
                                  labelText: 'Gate Mode (entry / exit)'),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Submit'),
                            onPressed: () {
                              setState(() {
                                _iotDeviceId =
                                    _iotDeviceIdTextEditingController.text;
                                if (_gateModeTextEditingController.text
                                        .toLowerCase() ==
                                    'entry') _gateMode = GateMode.entry;
                                if (_gateModeTextEditingController.text
                                        .toLowerCase() ==
                                    'exit') _gateMode = GateMode.exit;
                                onScanning();
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ));
                }
              },
            )
          ],
        ));
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
                  children: _floorStatus.keys
                      .map((key) => TableRow(children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                _floorName.keys.contains(key)
                                    ? _floorName[key]
                                    : key ?? '',
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
                          ]))
                      .toList())
              : CircularProgressIndicator()
        ],
      ),
    );
  }

  Widget scanningUI() {
    return Row(
      children: <Widget>[
        CircularProgressIndicator(),
        Padding(padding: EdgeInsets.only(left: 16.0)),
        Text(
          'Scanning License Plate...',
          style: Theme.of(context).textTheme.display1,
        )
      ],
    );
  }

  Widget entryScannedUI() {
    return Column(
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
                style: Theme.of(context)
                    .textTheme
                    .headline
                    .copyWith(color: Colors.red),
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
          keyboardType:
              TextInputType.numberWithOptions(signed: false, decimal: false),
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
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                entrySubmit();
              },
            ))
      ],
    );
  }

  Widget exitScannedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Spacer(),
        Text(
          'Something is wrong:',
          style: Theme.of(context).textTheme.display1,
        ),
        Padding(padding: EdgeInsets.only(top: 16.0)),
        _errorMessage.isNotEmpty
            ? Text(
                _errorMessage,
                style: Theme.of(context)
                    .textTheme
                    .headline
                    .copyWith(color: Colors.red),
              )
            : Container(),
        Padding(padding: EdgeInsets.only(top: 16.0)),
        _exitLicensePlateNotRecognized
            ? TextField(
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
              )
            : Container(),
        Padding(padding: EdgeInsets.only(top: 40.0)),
        Container(
            height: 80.0,
            width: 240.0,
            child: RaisedButton(
              child: Text(
                'Retry',
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(color: Colors.white),
              ),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                exitSubmit();
              },
            )),
        Spacer(),
        Align(alignment: Alignment.bottomRight, child: staffOverrideButton())
      ],
    );
  }

  Widget submittingUI() {
    return Row(
      children: <Widget>[
        CircularProgressIndicator(),
        Padding(padding: EdgeInsets.only(left: 16.0)),
        Text(
          'Submitting...',
          style: Theme.of(context).textTheme.display1,
        )
      ],
    );
  }

  Widget entrySubmittedUI() {
    return Column(
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
        Padding(padding: EdgeInsets.only(top: 80.0)),
        Text(
          'Check SMS for instruction to use our mobile app for payment and other services',
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget exitSubmittedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.check_circle,
          size: 100.0,
          color: Colors.green,
        ),
        Text(
          'Goodbye! We hope to see you again soon.',
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.only(top: 80.0)),
        Text(
          'Drive Safe!',
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget contactStaffUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Spacer(),
        Icon(
          Icons.error,
          size: 100.0,
          color: Colors.red,
        ),
        Text(
          'Please Contact Staff',
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.only(top: 80.0)),
        Text(
          _errorMessage,
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        ),
        Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: staffOverrideButton(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _isSignedIn
          ? null
          : SigninWidget(completion: () {
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
                            : Container())),
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
                            child: GestureDetector(
                              onLongPress: () => this.showStaffMenu(),
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  'Welcome to Smart Car Park',
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 9,
                              child: _gateFlowState == GateFlowState.scanning
                                  ? scanningUI()
                                  : _gateFlowState == GateFlowState.scanned
                                      ? _gateMode == GateMode.entry
                                          ? entryScannedUI()
                                          : exitScannedUI()
                                      : _gateFlowState ==
                                              GateFlowState.submitting
                                          ? submittingUI()
                                          : _gateFlowState ==
                                                  GateFlowState.submitted
                                              ? _gateMode == GateMode.entry
                                                  ? entrySubmittedUI()
                                                  : exitSubmittedUI()
                                              : _gateFlowState ==
                                                      GateFlowState.contactStaff
                                                  ? contactStaffUI()
                                                  : Container()),
                        ],
                      ),
                    )),
              ],
            )),
      ),
    );
  }
}
