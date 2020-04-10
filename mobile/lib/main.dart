import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_car_park_app/home_page.dart';
import 'package:stripe_payment/stripe_payment.dart';
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
    StripePayment.setOptions(
        StripeOptions(
            publishableKey: "pk_test_Kbnp8sRWTtMqKaXJdOKIO2hK00y1OinDK1",
            merchantId: "Test",
            androidPayMode: 'test'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Car Park',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}