import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car_park_app/home_page.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:uni_links/uni_links.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Stripe.init("pk_test_Kbnp8sRWTtMqKaXJdOKIO2hK00y1OinDK1",
        returnUrlForSca: "smartcarpark://sca/");
  }

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
