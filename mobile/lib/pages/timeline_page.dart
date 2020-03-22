import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_car_park_app/widgets/timeline_widget.dart';

class TimeLinePage extends StatefulWidget {
  TimeLinePage({
    key,
  }) : super(key: key);

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Table(children: [
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Car Plate Number:'),
                  Text('PK1234'),
                  SizedBox(width:55),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Parking Location:'),
                  Text('LG5 - 1'),
                  SizedBox(width:55),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Parking Duration:'),
                  Text('30 mins'),
                  SizedBox(width:55),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Parking Fees:'),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text('HKD 30 '),
                        Container(
                          width: 55,
                          height: 15,
                          child: RaisedButton(
                            onPressed: () {},
                            child: Text(
                                "Pay",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                )
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 150,
                    height: 15,
                    child: RaisedButton(
                      onPressed: () {},
                      child: Text(
                          "Parking Records",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          )
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 15,
                    child: RaisedButton(
                      onPressed: () {},
                      child: Text(
                          "Request Snapshot",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          )
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ]),
      ),
//        child: Row(
//          children: <Widget>[
//            SizedBox(width: 40),
//            Expanded(
//              flex: 1,
//              child: Column(
////                  mainAxisSize: MainAxisSize.min,
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
//                crossAxisAlignment: CrossAxisAlignment.start,
////                mainAxisAlignment: MainAxisAlignment.start,
//                children: <Widget>[
//                  Text('HA2213'),
//                  Text('LG5'),
//                  Text('30 mins'),
//                  Row(
//                    children: <Widget>[
//                      Text('HKD 30 '),
//                      ButtonTheme(
//                        minWidth: 10.0,
//                        height: 10.0,
//                        child: RaisedButton(
//                          onPressed: () {},
//                          child: Text("Pay"),
//                        ),
//                      ),
//                    ],
//                  ),
//                ],
//              ),
//            ),
//          ],
//        )
    );

    Widget infoSection = Container(
//        padding: const EdgeInsets.all(32),
        color: Color.fromRGBO(107, 176, 229, 100),
        height: 312,
        child: Column(
          children: <Widget>[
            snapShot,
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
          child: TimelinePage(title: 'Muslim Civilisation Doodles'),
          color: Color.fromRGBO(227, 241, 250, 100),
          height: 375,
        )
    );

    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
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
          )
      ),
    );
  }
}
