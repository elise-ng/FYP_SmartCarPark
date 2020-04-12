// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_fee_receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingFeeReceipt _$ParkingFeeReceiptFromJson(Map json) {
  return ParkingFeeReceipt(
    (json['total'] as num)?.toDouble(),
    json['durationInMinutes'] as int,
    json['license'] as String,
    (json['items'] as List)
        ?.map((e) => e == null ? null : ParkingFeeItem.fromJson(e as Map))
        ?.toList(),
  );
}

Map<String, dynamic> _$ParkingFeeReceiptToJson(ParkingFeeReceipt instance) =>
    <String, dynamic>{
      'total': instance.total,
      'durationInMinutes': instance.durationInMinutes,
      'license': instance.license,
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
    };

ParkingFeeItem _$ParkingFeeItemFromJson(Map json) {
  return ParkingFeeItem(
    json['name'] as String,
    json['quantity'] as int,
    (json['fee'] as num)?.toDouble(),
    (json['subtotal'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ParkingFeeItemToJson(ParkingFeeItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'fee': instance.fee,
      'subtotal': instance.subtotal,
    };
