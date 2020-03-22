import 'package:flutter/material.dart';

class SnapShotPage extends StatefulWidget {
  SnapShotPage({
    key,
  }) : super(key: key);

  @override
  _SnapShotPageState createState() => _SnapShotPageState();
}

class _SnapShotPageState extends State<SnapShotPage> {
  @override
  Widget build(BuildContext context) {
    Widget largeView = SafeArea(
        child: Column(
          children: <Widget>[
            Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "2020-01-01 19:41",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )
            ),
            Image.asset(
              'assets/blackCar.png',
              width: 319,
              height: 174,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 10,
            ),
            Divider(
                color: Colors.black
            )
          ],
        )
    );

    Widget gridView = SafeArea(
//      child: IgnorePointer(
      child: Column(
        children: <Widget>[
          Text(
            "2020",
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey
            ),
          ),
          GridView.count(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: true,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 3,
            children: <Widget>[
//              for (var i = 0; i < 10; i++) {
//                children.add(new ListTile());
//              }
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
              Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.teal[100],
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          '20/01 15:00',
                          style: TextStyle(

                          ),
                        ),
                      ),
                      Image.asset(
                        'assets/blackCar.png',
                        width: 93,
                        height: 60,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
              ),
            ],
          ),
        ],
      ),
//      )
    );

    return MaterialApp(
      home: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('Snapshot'),
          ),
          body: Column (
            children: [
              largeView,
              gridView,
            ],
          )
      ),
    );
  }
}
