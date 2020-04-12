import 'package:json_annotation/json_annotation.dart';

part 'parking_fee_receipt.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class ParkingFeeReceipt {
  ParkingFeeReceipt(this.total, this.durationInMinutes, this.license, this.items);

  double total;
  int durationInMinutes;
  String license;
  List<ParkingFeeItem> items;

  factory ParkingFeeReceipt.fromJson(Map json) => _$ParkingFeeReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingFeeReceiptToJson(this);
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