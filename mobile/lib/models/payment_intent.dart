import 'package:smart_car_park_app/models/parking_invoice.dart';

class PaymentIntent {
  PaymentIntent(this.clientSecret, this.invoice);

  String clientSecret;
  ParkingInvoice invoice;
}