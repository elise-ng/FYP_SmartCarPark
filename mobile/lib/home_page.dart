import 'package:flutter/material.dart';
import 'package:smart_car_park_app/pages/infomation_page.dart';
import 'package:smart_car_park_app/pages/parking_page.dart';
import 'package:smart_car_park_app/pages/payment_page.dart';
import 'package:smart_car_park_app/pages/timeline_page.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: [
          ParkingPage(
            key: PageStorageKey('Parking'),
          ),
          InformationPage(
            key: PageStorageKey('Information'),
          ),
          PaymentPage(
            key: PageStorageKey('Payment'),
          ),
          TimeLinePage(
            key: PageStorageKey('Timeline'),
          ),
        ][_currentIndex],
        bucket: this.bucket,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: this._currentIndex,
        iconSize: 20,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.local_parking),
            title: new Text('Parking'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.info_outline),
            title: new Text('Information'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            title: Text('Payment'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            title: Text('Timeline'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
