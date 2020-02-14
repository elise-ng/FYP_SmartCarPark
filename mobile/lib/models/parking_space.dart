import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' hide LatLng;
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
import 'dart:math';

enum ParkingState {
  Vacant,
  Occupied,
  Changing,
  Disabled,
  Undefined,
}

class ParkingSpace extends Equatable {
  final String id;
  final LatLng position;
  final String floorId;
  final double widthInMeters;
  final double heightInMeters;
  final double bearing;

  ParkingState state;
  String imageUrl;
  Timestamp time;
  String vehicleId;

  LatLng center;

  ParkingSpace({
    this.id,
    this.position,
    this.floorId,
    this.state = ParkingState.Vacant,
    this.imageUrl = "",
    this.time,
    this.vehicleId = "",
    this.widthInMeters = 2.2,
    this.heightInMeters = 4.8,
    this.bearing = 0,
  }) {
    if (time == null)
      time = Timestamp.now();

    /// Calculate the center of the parking space
    this.center = Distance(roundResult: true)
        .offset(this.position.toUtilsLatLng(), _hypotenuse(this.heightInMeters/2, this.widthInMeters/2), radianToDeg(atan2(this.heightInMeters, this.widthInMeters) + PI/2))
        .toGoogleLatLng();
  }

  ParkingSpace.fromDocument(DocumentSnapshot document): this(
    id: document.documentID,
    position: (document.data["position"] as GeoPoint).toLatLng(),
    floorId: document.data["floorId"] as String,
    state: EnumToString.fromString(ParkingState.values, document.data["state"]) ?? ParkingState.Undefined,
    imageUrl: document.data["imageUrl"] as String ?? "",
    time: document.data["time"] as Timestamp ?? Timestamp.now(),
    vehicleId: document.data["vehicleId"] as String ?? "",
    widthInMeters: (document.data["widthInMeters"] as double) ?? 2.2,
    heightInMeters: (document.data["heightInMeters"] as double) ?? 4.8,
    bearing: (document.data["bearing"] as double) ?? 0,
  );

  Map<String, dynamic> toDataMap() {
    return {
      "position": this.position.toGeoPoint(),
      "floorId": this.floorId,
      "state": EnumToString.parse(this.state).toLowerCase(),
      "imageUrl": this.imageUrl,
      "time": this.time,
      "vehicleId": this.vehicleId,
    };
  }

  double _hypotenuse(double x, double y) {
    return sqrt(pow(x, 2) + pow(y, 2));
  }

  Color getStatusColor() {
    switch (this.state) {
      case ParkingState.Vacant:
        return Colors.green[400];
      case ParkingState.Occupied:
        return Colors.red[400];
      case ParkingState.Changing:
        return Colors.yellow[400];
      case ParkingState.Disabled:
        return Colors.grey[400];
      default:
        return Colors.grey[400];
    }
  }

  @override
  List<Object> get props => [this.id];
}
