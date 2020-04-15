import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_car_park_app/widgets/signin_widget.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class InformationPage extends StatefulWidget {
  InformationPage({
    key,
  }) : super(key: key);

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {

  Map<String, dynamic> _gateRecord;
  String _currentLocation;
  List<Map<String, dynamic>> _iotStateChangesPrev = [];
  List<Map<String, dynamic>> _iotStateChangesNew = [];
  List<Map<String, dynamic>> _iotStateChanges = [];

  StreamSubscription _gateRecordSubscription;
  StreamSubscription _iotStateChangesPrevSubscription;
  StreamSubscription _iotStateChangesNewSubscription;

  void listenToGateRecord() async {
    await this._gateRecordSubscription?.cancel();
    this._gateRecordSubscription = null;
    this._gateRecordSubscription = Firestore.instance.collection('gateRecords').where('phoneNumber', isEqualTo: '+85212345678').snapshots().listen((snapshot) {
      try {
        this._gateRecord = (snapshot.documents..sort((a, b) => (a.data['entryScanTime'] as Timestamp).compareTo(b.data['entryScanTime'] as Timestamp))).first.data;
      } catch (e) { // list empty
        this._gateRecord = null;
        setState(() {});
        return;
      }
      debugPrint('hello1');
      this.listenToIotStateChanges();
      setState(() {});
    });
  }

  void listenToIotStateChanges() async {
    await this._iotStateChangesPrevSubscription?.cancel();
    this._iotStateChangesPrevSubscription = null;
    await this._iotStateChangesNewSubscription?.cancel();
    this._iotStateChangesNewSubscription = null;
    debugPrint('hello2');
    if (this._gateRecord == null || this._gateRecord['vehicleId'] == null) {
      this._iotStateChangesNew = [];
      this._iotStateChangesPrev = [];
      this._iotStateChanges = [];
      setState(() {});
      return;
    };
    final vehicleId = this._gateRecord['vehicleId'] as String;
    debugPrint(vehicleId);
    this._iotStateChangesPrevSubscription = Firestore.instance.collection('iotStateChanges')
        .where('previousState.vehicleId', isEqualTo: vehicleId)
        .where('time', isGreaterThanOrEqualTo: _gateRecord['entryScanTime'] as Timestamp)
        .where('time', isLessThanOrEqualTo: _gateRecord['exitScanTime'] as Timestamp)
        .snapshots().listen((snapshot) {
      debugPrint(snapshot.documents.toString());
      this._iotStateChangesPrev = snapshot.documents.map((snapshot) => snapshot.data).toList();
      this._iotStateChanges = [... this._iotStateChangesPrev, ... this._iotStateChangesNew]..sort((a, b) => -1 * (a['time'] as Timestamp).compareTo(b['time'] as Timestamp));
      this.refreshCurrentLocation();
      setState(() {});
    });
    this._iotStateChangesNewSubscription = Firestore.instance.collection('iotStateChanges')
        .where('newState.vehicleId', isEqualTo: vehicleId)
        .where('time', isGreaterThanOrEqualTo: _gateRecord['entryScanTime'] as Timestamp)
        .where('time', isLessThanOrEqualTo: _gateRecord['exitScanTime'] as Timestamp)
        .snapshots().listen((snapshot) {
      debugPrint(snapshot.documents.toString());
      this._iotStateChangesNew = snapshot.documents.map((snapshot) => snapshot.data).toList();
      this._iotStateChanges = [... this._iotStateChangesPrev, ... this._iotStateChangesNew]..sort((a, b) => -1 * (a['time'] as Timestamp).compareTo(b['time'] as Timestamp));
      this.refreshCurrentLocation();
      setState(() {});
    });
  }

  void refreshCurrentLocation() {
    final lastVacant = this._iotStateChanges.firstWhere((change) => change['newState']['state'] == 'vacant');
    final lastOccupy = this._iotStateChanges.firstWhere((change) => change['newState']['state'] == 'occupied');
    if ((lastVacant['time'] as Timestamp).compareTo(lastOccupy['time'] as Timestamp) > 0) { // vacant is later then occupy
      _currentLocation = null;
    } else {
      _currentLocation = lastOccupy['deviceId'];
    }
  }

  @override
  void initState() {
    super.initState();
    this.listenToGateRecord();
  }

  Widget makeTableRow(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
              flex: 4,
              child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    title,
                    style: Theme.of(context).primaryTextTheme.subtitle1,
                    textAlign: TextAlign.right,
                  )
              )
          ),
          Expanded(
              flex: 6,
              child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).primaryTextTheme.subtitle1,
                    textAlign: TextAlign.left,
                  )
              )
          ),
        ],
      )
    );
  }

  TimelineModel makeTimelineModel(Map<String, dynamic> iotStateChange) {
    String message = '';
    if (iotStateChange['newState']['state'] == 'occupied') {
      message = 'Vehicle parked into ${iotStateChange['deviceId']}';
    } else if (iotStateChange['newState']['state'] == 'vacant') {
      message = 'Vehicle moved out of ${iotStateChange['deviceId']}';
    } else {
      message = 'Status changed from ${iotStateChange['previousState']['state']} to ${iotStateChange['newState']['state']} at ${iotStateChange['deviceId']}';
    }
    debugPrint(message);
    return TimelineModel(
      Container(
        width: double.maxFinite,
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    timeago.format((iotStateChange['time'] as Timestamp).toDate()),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )
          ),
        ),
      ),
      icon: Icon(Icons.info_outline, color: Colors.white,),
      iconBackground: Theme.of(context).accentColor,
      position: TimelineItemPosition.left
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
        this._gateRecord != null
        ? Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).accentColor,
                child: SafeArea(
                  minimum: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      makeTableRow('Vehicle ID', this._gateRecord['vehicleId'] ?? '-'),
                      makeTableRow('Parked Location', this._currentLocation ?? '-'),
                      makeTableRow('Parked Duration', DateTime.now().difference((this._gateRecord['entryConfirmTime'] as Timestamp).toDate()).inMinutes.toString() + ' Minutes'),
                      makeTableRow('Amount Due', '???'),
                    ],
                  ),
                )
              ),
              Expanded(
                child: Timeline(
                  children: <TimelineModel>[
                    // TODO: make exit time card
                    ..._iotStateChanges.map((change) => makeTimelineModel(change)).toList(),
                    // TODO: make entry time card
                  ],
                  position: TimelinePosition.Left,
                  physics: BouncingScrollPhysics(),
                ),
              )
            ],
          )
        : Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
