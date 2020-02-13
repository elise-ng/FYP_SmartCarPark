// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_space.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingSpace _$ParkingSpaceFromJson(Map<String, dynamic> json) {
  return ParkingSpace(
    id: json['id'] as String,
    latitude: (json['latitude'] as num)?.toDouble(),
    longitude: (json['longitude'] as num)?.toDouble(),
    status: _$enumDecodeNullable(_$ParkingStatusEnumMap, json['status']),
    widthInMeters: (json['widthInMeters'] as num)?.toDouble(),
    heightInMeters: (json['heightInMeters'] as num)?.toDouble(),
    bearing: (json['bearing'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ParkingSpaceToJson(ParkingSpace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'widthInMeters': instance.widthInMeters,
      'heightInMeters': instance.heightInMeters,
      'bearing': instance.bearing,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
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
