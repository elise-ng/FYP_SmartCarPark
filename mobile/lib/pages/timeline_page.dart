import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_car_park_app/widgets/timeline_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as Math;

class TimeLinePage extends StatefulWidget {
  TimeLinePage({
    key,
  }) : super(key: key);

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class IotStates {
  final CollectionReference iotStateCollection = Firestore.instance.collection("iotStates");

  Stream<QuerySnapshot> get iotStates{
    return iotStateCollection.snapshots();
  }
}

class UserRecords {
  final CollectionReference userRecordsCollection = Firestore.instance.collection("userRecords");

  Stream<QuerySnapshot> get iotStates{
    return userRecordsCollection.snapshots();
  }
}


class _TimeLinePageState extends State<TimeLinePage> {

//  Future<List<DocumentSnapshot>> getVehicleID() async{
//    var data = await Firestore.instance.collection('userRecords').getDocuments();
//    var vehicleID = data.documents;
//    return vehicleID;
//  }

  @override
  void initState() {
    super.initState();
    this._getData();
  }

//  void getData() async {
////    print("test");
////    Firestore.instance
////        .collection('iotStateChanges')
//////          .where("topic", isEqualTo: "flutter")
////        .snapshots()
////        .listen((data) =>
////        data.documents.forEach((doc) => print(doc["deviceId"]))); //Parking location
//
//
////
////    for (var VehicleId in gateRecords.documents) {
////      print(VehicleId.data['paymentStatus']);
////    }
//
//    //if phoneNumber in userRecords = "+85212345678" --> gateRecords: entryConfirmTime is before now() and exitConfirmTime is null
//    // --> get vehicleId, iotStateChanges: Parking location, Duration = entryconfirm - now,
//    // fees
//
//    //vehicleId
//    FirebaseUser user;
////    print(user.phoneNumber);
//    var now = new DateTime.now();
//    var vehicleId;
//    var parkingLocation;
//    var parkingDuration;
//    num parkingDurationInMinutes;
//    var parkingFee;
//    QuerySnapshot gateRecords;
//    QuerySnapshot iotStateChanges;
//    var parkingInfo = Map();
////    List<String> parkingInfo = [];
//
//    String _printDuration(Duration duration) {
//      String twoDigits(int n) {
//        if (n >= 10) return "$n";
//        return "0$n";
//      }
//
//      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
//      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
//      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
//    }
//
//    QuerySnapshot userRecords = await Firestore.instance
//        .collection('userRecords')
//        .where("phoneNumber", isEqualTo:  "+85212345678") //need change to user.phoneNumber
//        .getDocuments();
//
//    List<DocumentSnapshot> matchUserRecords = userRecords.documents.toList();
//
//    for (var matchUserRecord in matchUserRecords) {
////        print(matchUserRecord.data['vehicleId']);
//
//    //TODO:Uncomment
////        gateRecords = await Firestore.instance
////            .collection('gateRecords')
////            .where("vehicleId", isEqualTo: matchUserRecord.data['vehicleId'])
////            .where("entryConfirmTime", isLessThanOrEqualTo:  now)
////            .where('exitConfirmTime', isEqualTo: null)
////            .getDocuments();
//
//        gateRecords = await Firestore.instance
//            .collection('gateRecords')
//            .getDocuments();
//
//        for (var gateRecord in gateRecords.documents) {
//          //TODO: delete
//          if (!gateRecord.data.containsKey('entryConfirmTime')) {
//            continue;
//          }
//          var entryConfirmTime = gateRecord.data['entryConfirmTime'].toDate();
//          vehicleId = gateRecord.data['vehicleId'];
//          parkingDuration = now.difference(entryConfirmTime);
//          parkingDurationInMinutes = parkingDuration.inMinutes;
//          parkingFee = (Math.min(120, parkingDurationInMinutes)/60) * 20 + (Math.max(0, parkingDurationInMinutes - 120)/60) * 50;
//
//          iotStateChanges = await Firestore.instance
//              .collection('iotStateChanges')
//              .getDocuments();
//
//          for (var iotStateChange in iotStateChanges.documents) {
//            var previousState = iotStateChange.data['previousState'];
//            if (previousState['vehicleId'] == vehicleId) {
//              parkingLocation = iotStateChange['deviceId'];
//            }
//          }
//        }
//
//        parkingInfo['vehicleId'] = vehicleId;
//        parkingInfo['parkingLocation'] = parkingLocation;
//        parkingInfo['parkingDuration'] = _printDuration(parkingDuration);
//        parkingInfo['parkingFee'] = parkingFee.round().toString();
//    }
//  }

  String vehicleId = "";
  String parkingLocation = "";
  String parkingDuration = "";
  String parkingFee = "";

    _getData() async {
      getData('vehicleId').then((String val){
        setState(() {
          vehicleId = val;
        });
      });
      getData('parkingLocation').then((String val){
        setState(() {
          parkingLocation = val;
        });
      });
      getData('parkingDuration').then((String val){
        setState(() {
          parkingDuration = val;
        });
      });
      getData('parkingFee').then((String val){
        setState(() {
          parkingFee = val;
        });
      });
    }

  @override
  Widget build(BuildContext context) {

    var now = new DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

//    void getValue() {
//      for (var doc in Firestore.instance.collection("userRecords").document('')) {
//        print(doc.data);
//      }
//    }

    Widget snapShot = SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/blackCar.png',
            width: 262,
            height: 94,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ],
      ),
    );

    Widget infoTable = Container(
//      child: Padding(
//        padding: EdgeInsets.symmetric(horizontal: 10.0),
//        child: Table(children: [
//          TableRow(children: [
//            TableCell(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Text('Car Plate Number:'),
//                  Text('PK1234'),
//                  SizedBox(width:55),
//                ],
//              ),
//            ),
//          ]),
//          TableRow(children: [
//            TableCell(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Text('Parking Location:'),
//                  Text('LG5 - 1'),
//                  SizedBox(width:55),
//                ],
//              ),
//            ),
//          ]),
//          TableRow(children: [
//            TableCell(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Text('Parking Duration:'),
//                  Text('30 mins'),
//                  SizedBox(width:55),
//                ],
//              ),
//            ),
//          ]),
//          TableRow(children: [
//            TableCell(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceAround,
//                children: <Widget>[
//                  Text('Parking Fees:'),
//                  Container(
//                    child: Row(
//                      children: <Widget>[
//                        Text('HKD 30 '),
//                        Container(
//                          width: 55,
//                          height: 15,
//                          child: RaisedButton(
//                            onPressed: () {},
//                            child: Text(
//                                "Pay",
//                                style: TextStyle(
//                                  fontSize: 12,
//                                  color: Colors.black,
//                                )
//                            ),
//                          ),
//                        )
//                      ],
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          ]),
//          TableRow(children: [
//            TableCell(
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                children: <Widget>[
//                  Container(
//                    width: 150,
//                    height: 15,
//                    child: RaisedButton(
//                      onPressed: () {},
//                      child: Text(
//                          "Parking Records",
//                          style: TextStyle(
//                            fontSize: 12,
//                            color: Colors.black,
//                          )
//                      ),
//                    ),
//                  ),
//                  Container(
//                    width: 150,
//                    height: 15,
//                    child: RaisedButton(
//                      onPressed: () {},
//                      child: Text(
//                          "Request Snapshot",
//                          style: TextStyle(
//                            fontSize: 12,
//                            color: Colors.black,
//                          )
//                      ),
//                    ),
//                  )
//                ],
//              ),
//            ),
//          ]),
//        ]),
//      ),
//
//        child: Row(
//
//          children: <Widget>[
//            SizedBox(width: 80),
//            Expanded(
//
//              flex: 1,
//              child: Column(
//
//                mainAxisSize: MainAxisSize.min,
//                crossAxisAlignment: CrossAxisAlignment.start,
////                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Text('Car Plate Number:'),
//                  Text('Parking Location:'),
//                  Text('Parking Duration:'),
//                  Text('Parking Fees:'),
//                ],
//              ),
//            ),
//            Expanded(
//              flex: 1,
//              child: Column(
//                mainAxisSize: MainAxisSize.min,
//                crossAxisAlignment: CrossAxisAlignment.start,
////                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget> [
//                  Text('HA2213'),
//                  Text('LG5'),
//                  Text('30 mins'),
////                  Text('test'),
////                  Expanded(
//
//                    Row(
//                      children: <Widget>[
//                        Text('HKD 30 '),
//                        SizedBox(
//                          width: 57,
//                          height: 25,
//                          child: ButtonTheme(
////                    minWidth: 10.0,
////                    height: 10.0,
//                            child: RaisedButton(
//                              onPressed: () {},
//                              child: Text("Pay"),
//                            ),
//                          ),
//                        ),
////                        ButtonTheme(
////                          minWidth: 10.0,
////                          height: 10.0,
////                          child: RaisedButton(
////                            onPressed: () {},
////                            child: Text("Pay"),
////                          ),
////                        ),
//                      ],
//                    ),
////                  ),
//                ],
//              ),
//            ),
//          ],
//        )

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
//          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 80),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text('Car Plate Number:'),
                    Text(vehicleId),
                  ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Parking Location:'),
                  Text(parkingLocation),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
//                  Spacer(flex: 3),
                  Text('Parking Duration:'),
//                  Spacer(flex: 3),
                  Text(parkingDuration),
//                  Spacer(flex: 2),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
//                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Spacer(flex: 8),
                  Text('Parking Fees:'),
                  Spacer(flex: 9),
                  Text(parkingFee),
                  Spacer(flex: 1),
                  SizedBox(
                    width: 60,
                    height: 17,
                    child: ButtonTheme(
//                    minWidth: 10.0,
//                    height: 10.0,
                      child: RaisedButton(
                        onPressed: () => getData('vehicleId'),
                        child: Text(
                            "Pay",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
//              mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 190,
                    height: 25,
                    child: ButtonTheme(
//                    minWidth: 10.0,
//                    height: 10.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(
                            "Payment Records",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    height: 25,
                    child: ButtonTheme(
//                    minWidth: 10.0,
//                    height: 10.0,
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(
                          "Request Snapshot",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        )
    );

    Widget infoSection = Container(
//        padding: const EdgeInsets.all(32),
        color: Color.fromRGBO(107, 176, 229, 100),
        height: 312,
        child: Column(
          children: <Widget>[
            snapShot,
            SizedBox(height:20),
            infoTable,
          ],
        )
    );

    Widget dateSection = Container(
        color: Color.fromRGBO(33, 114, 191, 100),
        height: 61,
        child: Center(
          child: Text(
            formattedDate,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 25.0,
              fontFamily: 'Roboto',
            ),
          ),
        )
    );

    Widget timeLine = Container(
        child: Container(
          child: TimelinePage(title: ''),
          color: Color.fromRGBO(227, 241, 250, 100),
          height: 375,
        )
    );




//    return StreamProvider<QuerySnapshot>.value(
//      value: IotStates().iotStates,
    return Scaffold (
      body: Column (
          children: [
            infoSection,
            dateSection,
            timeLine,
//              Timeline(
//                  children: items,
//                  position: TimelinePosition.Center
//              ),
          ],
        ),
      );
  }
  Future<String> getData(data) async {
    //if phoneNumber in userRecords = "+85212345678" --> gateRecords: entryConfirmTime is before now() and exitConfirmTime is null
    // --> get vehicleId, iotStateChanges: Parking location, Duration = entryconfirm - now,
    // fees

    //vehicleId
    FirebaseUser user;
//    print(user.phoneNumber);
    var now = new DateTime.now();
    var vehicleId;
    var parkingLocation;
    var parkingDuration;
    num parkingDurationInMinutes;
    var parkingFee;
    QuerySnapshot gateRecords;
    QuerySnapshot iotStateChanges;
//      var parkingInfo = Map();

    String _printDuration(Duration duration) {
      String twoDigits(int n) {
        if (n >= 10) return "$n";
        return "0$n";
      }

      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    QuerySnapshot userRecords = await Firestore.instance
        .collection('userRecords')
        .where("phoneNumber", isEqualTo:  "+85212345678") //need change to user.phoneNumber
        .getDocuments();

    List<DocumentSnapshot> matchUserRecords = userRecords.documents.toList();

    for (var matchUserRecord in matchUserRecords) {
//        print(matchUserRecord.data['vehicleId']);

      //TODO:Uncomment
//        gateRecords = await Firestore.instance
//            .collection('gateRecords')
//            .where("vehicleId", isEqualTo: matchUserRecord.data['vehicleId'])
//            .where("entryConfirmTime", isLessThanOrEqualTo:  now)
//            .where('exitConfirmTime', isEqualTo: null)
//            .getDocuments();

      gateRecords = await Firestore.instance
          .collection('gateRecords')
          .getDocuments();

      for (var gateRecord in gateRecords.documents) {
        //TODO: delete
        if (!gateRecord.data.containsKey('entryConfirmTime')) {
          continue;
        }
        var entryConfirmTime = gateRecord.data['entryConfirmTime'].toDate();
        vehicleId = gateRecord.data['vehicleId'];
        parkingDuration = now.difference(entryConfirmTime);
        parkingDurationInMinutes = parkingDuration.inMinutes;
        parkingFee = (Math.min(120, parkingDurationInMinutes)/60) * 20 + (Math.max(0, parkingDurationInMinutes - 120)/60) * 50;

        iotStateChanges = await Firestore.instance
            .collection('iotStateChanges')
            .getDocuments();

        for (var iotStateChange in iotStateChanges.documents) {
          var previousState = iotStateChange.data['previousState'];
          if (previousState['vehicleId'] == vehicleId) {
            parkingLocation = iotStateChange['deviceId'];
          }
        }
      }

      switch (data) {
        case 'vehicleId':{
          return await vehicleId;
        }
        break;
        case 'parkingLocation':{
          return await parkingLocation;
        }
        break;
        case 'parkingDuration':{
          return await _printDuration(parkingDuration);
        }
        break;
        case 'parkingFee':{
          return await parkingFee.round().toString();
        }
        break;
      }
//        parkingInfo['vehicleId'] = vehicleId;
//        parkingInfo['parkingLocation'] = parkingLocation;
//        parkingInfo['parkingDuration'] = _printDuration(parkingDuration);
//        parkingInfo['parkingFee'] = parkingFee.round().toString();
    }
  }


}
