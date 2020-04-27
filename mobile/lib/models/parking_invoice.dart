import 'package:json_annotation/json_annotation.dart';

part 'parking_invoice.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class ParkingInvoice {
  ParkingInvoice(this.total, this.durationInMinutes, this.license, this.items);

  double total;
  int durationInMinutes;
  String license;
  List<ParkingFeeItem> items;

  factory ParkingInvoice.fromJson(Map json) => _$ParkingInvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingInvoiceToJson(this);
}

@JsonSerializable(anyMap: true)
class ParkingFeeItem {
  ParkingFeeItem(this.name, this.quantity, this.fee, this.subtotal);

  String name;
  int quantity;
  double fee;
  double subtotal;

  factory ParkingFeeItem.fromJson(Map json) => _$ParkingFeeItemFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingFeeItemToJson(this);
}