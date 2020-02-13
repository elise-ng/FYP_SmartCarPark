import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong/latlong.dart' hide LatLng;
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
import 'dart:math';

part 'parking_space.g.dart';

enum ParkingStatus {
  Vacant,
  Occupied,
  Leaving,
  Disabled,
}

@JsonSerializable()
class ParkingSpace {
  final String id;

  final double widthInMeters;
  final double heightInMeters;
  final double bearing;

  final double latitude;
  final double longitude;

  ParkingStatus status;

  @JsonKey(ignore: true)
  LatLng position;

  @JsonKey(ignore: true)
  LatLng center;

  ParkingSpace({
    this.id,
    this.latitude,
    this.longitude,
    this.status = ParkingStatus.Vacant,
    this.widthInMeters = 2.2,
    this.heightInMeters = 4.8,
    this.bearing = 0,
  }) {
    this.position = LatLng(this.latitude, this.longitude);

    /// Calculate the center of the parking space
    this.center = Distance(roundResult: true)
        .offset(this.position.toUtilsLatLng(), _hypotenuse(this.heightInMeters/2, this.widthInMeters/2), radianToDeg(atan2(this.heightInMeters, this.widthInMeters) + PI/2))
        .toGoogleLatLng();
  }

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

  double _hypotenuse(double x, double y) {
    return sqrt(pow(x, 2) + pow(y, 2));
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
