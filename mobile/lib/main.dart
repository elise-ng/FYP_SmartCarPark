import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_car_park_app/global_variables.dart';
import 'package:smart_car_park_app/splash_page.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const publishableKey = "pk_test_Kbnp8sRWTtMqKaXJdOKIO2hK00y1OinDK1";

  @override
  void initState() {
    super.initState();
    Stripe.init(publishableKey, returnUrlForSca: "smartcarpark://sca");
    StripeApi.init(publishableKey);
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
      child: ChangeNotifierProvider.value(
        value: userRecord,
        child: MaterialApp(
          title: 'Smart Car Park',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SplashPage(),
        ),
      ),
    );
  }
}
