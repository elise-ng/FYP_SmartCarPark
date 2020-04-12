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

  Map<String, dynamic> _gateRecord = {};
  List<Map<String, dynamic>> _iotStateChangesPrev = [];
  List<Map<String, dynamic>> _iotStateChangesNew = [];
  List<Map<String, dynamic>> _iotStateChanges = [];

  final ScrollController _scrollController = ScrollController();

  void getGateRecord() {
    Firestore.instance.collection('gateRecords').where('phoneNumber', isEqualTo: '+85212345678').snapshots().listen((snapshot) {
      this._gateRecord = (snapshot.documents..sort((a, b) => (a.data['entryScanTime'] as Timestamp).compareTo(b.data['entryScanTime'] as Timestamp))).first.data;
      if (this._gateRecord['vehicleId'] != null) this.getIotStateChanges();
      setState(() {});
    });
  }

  void getIotStateChanges() {
    final vehicleId = this._gateRecord['vehicleId'] as String;
    if (vehicleId == null) return;
    Firestore.instance.collection('iotStateChanges').where('previousState.vehicleId', isEqualTo: vehicleId).where('time', isGreaterThanOrEqualTo: _gateRecord['entryScanTime'] as Timestamp).snapshots().listen((snapshot) {
      this._iotStateChangesPrev = snapshot.documents.map((snapshot) => snapshot.data).toList();
      this._iotStateChanges = [... this._iotStateChangesPrev, ... this._iotStateChangesNew]..sort((a, b) => -1 * (a['time'] as Timestamp).compareTo(b['time'] as Timestamp));
      setState(() {});
    });
    Firestore.instance.collection('iotStateChanges').where('newState.vehicleId', isEqualTo: vehicleId).where('time', isGreaterThanOrEqualTo: _gateRecord['entryScanTime'] as Timestamp).snapshots().listen((snapshot) {
      this._iotStateChangesNew = snapshot.documents.map((snapshot) => snapshot.data).toList();
      this._iotStateChanges = [... this._iotStateChangesPrev, ... this._iotStateChangesNew]..sort((a, b) => -1 * (a['time'] as Timestamp).compareTo(b['time'] as Timestamp));
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    this.getGateRecord();
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
      Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).accentColor,
            child: SafeArea(
              minimum: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  makeTableRow('Vehicle ID', this._gateRecord['vehicleId']),
                  makeTableRow('Parked Location', '???'),
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
              controller: _scrollController,
            ),
          )
        ],
      )
    );
  }
}
