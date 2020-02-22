import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  scanned
}

class _KioskPageState extends State<KioskPage> {

  bool _isSignedIn = FirebaseAuth.instance.currentUser() != null;

  GateMode _gateMode = GateMode.entry;
  GateFlowState _gateFlowState = GateFlowState.scanning;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _isSignedIn ? null : SigninWidget(completion: () {
        setState(() {
          this._isSignedIn = FirebaseAuth.instance.currentUser() != null;
        });
      }),
      body: Row(
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
                children: <Widget>[
                  Text(
                    'Welcome to Smart Car Park',
                    style: Theme.of(context).textTheme.display2,
                  ),
                  _gateFlowState == GateFlowState.scanning
                  ? Expanded(
                    child:  Row(
                      mainAxisSize: MainAxisSize.min,
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
                  : Container()
                ],
              ),
            )
          ),
        ],
      )
    );
  }
}
