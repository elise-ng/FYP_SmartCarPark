import 'package:flutter/material.dart';
import 'package:smart_car_park_app/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard on tap
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        title: 'Smart Car Park',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      )
    );
  }
}