// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_space.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSpace _$ParkingSpaceFromJson(Map<String, dynamic> json) {
  return ParkingSpace(
    spaceID: json['space_id'] as String,
    latLng:
        ParkingSpace._latLngFromJson(json['lat_lng'] as Map<String, dynamic>),
    status: _$enumDecodeNullable(_$ParkingStatusEnumMap, json['status']),
  );
}

Map<String, dynamic> _$ParkingSpaceToJson(ParkingSpace instance) =>
    <String, dynamic>{
      'space_id': instance.spaceID,
      'lat_lng': ParkingSpace._latLngToJson(instance.latLng),
      'status': _$ParkingStatusEnumMap[instance.status],
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ParkingStatusEnumMap = {
  ParkingStatus.Vacant: 'Vacant',
  ParkingStatus.Occupied: 'Occupied',
  ParkingStatus.Leaving: 'Leaving',
  ParkingStatus.Disabled: 'Disabled',
};
