import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_car_park_app/pages/information_page.dart';
import 'package:smart_car_park_app/pages/car_park_map_page.dart';
import 'package:smart_car_park_app/pages/login_page.dart';
import 'models/user_record.dart';
import 'pages/car_park_map_page.dart';
import 'pages/information_page.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isAuthenticated = false;

  List<Widget> _unauthenticatedTabs = [
    CarParkMapPage(),
    LoginPage(),
  ];
  List<BottomNavigationBarItem> _unauthenticatedBarItems = [
    BottomNavigationBarItem(
      icon: new Icon(Icons.local_parking),
      title: new Text('Parking'),
    ),
    BottomNavigationBarItem(
      icon: new Icon(Icons.person),
      title: new Text('Login'),
    ),
  ];

  List<Widget> _authenticatedTabs = [
    CarParkMapPage(),
    InformationPage(),
  ];
  List<BottomNavigationBarItem> _authenticatedBarItems = [
    BottomNavigationBarItem(
      icon: new Icon(Icons.local_parking),
      title: new Text('Parking'),
    ),
    BottomNavigationBarItem(
      icon: new Icon(Icons.info_outline),
      title: new Text('Information'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    this._isAuthenticated = Provider.of<UserRecord>(context, listen: false).isAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    UserRecord _userRecord = Provider.of<UserRecord>(context);
    if(!this._isAuthenticated && _userRecord.isAuthenticated()) {
      /// Just logged in, change back to map view
      WidgetsBinding.instance.addPostFrameCallback((_) => this.setState(() { this._currentIndex = 0; }));
    }
    this._isAuthenticated = _userRecord.isAuthenticated();

    return Scaffold(
      body: IndexedStack(
        index: this._currentIndex,
        children: this._isAuthenticated ? _authenticatedTabs : _unauthenticatedTabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: this._currentIndex,
        iconSize: 20,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: this._isAuthenticated ? _authenticatedBarItems : _unauthenticatedBarItems,
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
