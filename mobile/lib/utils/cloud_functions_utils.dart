import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_car_park_app/models/parking_invoice.dart';
import 'package:smart_car_park_app/models/payment_intent.dart';

class CloudFunctionsUtils {
  static Future<dynamic> _call(
      String functionName, Map<String, dynamic> params) async {
    HttpsCallableResult result =
        await CloudFunctions(app: FirebaseApp.instance, region: 'asia-east2')
            .getHttpsCallable(functionName: functionName)
            .call(params);

    Map data = result.data as Map;

    if (data.containsKey("success") && !data["success"]) {
      throw Exception("Data is null");
    }

    return data;
  }

  static Future<ParkingInvoice> getParkingInvoice(String gateRecordId) async {
    Map data = await _call("getParkingInvoice", {"gateRecordId": gateRecordId});
    return ParkingInvoice.fromJson(data["invoice"]);
  }

  static Future<PaymentIntent> createPaymentIntent(String gateRecordId) async {
    Map data = await _call("createPaymentIntent", {"gateRecordId": gateRecordId});
    return PaymentIntent(data["clientSecret"], ParkingInvoice.fromJson(data["invoice"]));
  }

  static Future<String> getEphemeralKey(String apiVersion) async {
    final data =
        await _call('getEphemeralKey', {'stripeApiVersion': apiVersion});
    final key = data['key'];
    final jsonKey = json.encode(key);
    return jsonKey;
  }
}
