import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'parking_space.g.dart';

enum ParkingStatus {
  Vacant,
  Occupied,
  Leaving,
  Disabled,
}

@JsonSerializable()
class ParkingSpace {
  @JsonKey(name: 'space_id')
  final String spaceID;

  @JsonKey(name: 'lat_lng', fromJson: _latLngFromJson, toJson: _latLngToJson)
  final LatLng latLng;

  ParkingStatus status;

  ParkingSpace({
    this.spaceID,
    this.latLng,
    this.status = ParkingStatus.Vacant,
  });

  factory ParkingSpace.fromJson(Map<String, dynamic> json) =>
      _$ParkingSpaceFromJson(json);

  Map<String, dynamic> toJson() => _$ParkingSpaceToJson(this);

  static LatLng _latLngFromJson(Map<String, dynamic> json) {
    if(!json.containsKey("latitude") || !json.containsKey("longitude")) {
      return null;
    }
    return LatLng(json["latitude"], json["longitude"]);
  }

  static Map<String, dynamic> _latLngToJson(LatLng latLng) {
    return {
      "latitude": latLng.latitude,
      "longitude": latLng.longitude,
    };
  }

  Color getStatusColor() {
    switch (this.status) {
      case ParkingStatus.Vacant:
        return Colors.green[400];
      case ParkingStatus.Occupied:
        return Colors.red[400];
      case ParkingStatus.Leaving:
        return Colors.yellow[400];
      case ParkingStatus.Disabled:
        return Colors.grey[400];
      default:
        return Colors.grey[400];
    }
  }
}
