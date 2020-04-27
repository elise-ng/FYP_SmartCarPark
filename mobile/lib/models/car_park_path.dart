import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';

class CarParkPath extends Equatable{
  final String id;
  final bool isParkingPath;
  final List<LatLng> points;

  CarParkPath({
    this.id,
    this.isParkingPath,
    this.points,
  });

  CarParkPath.fromMap(String id, Map<dynamic, dynamic> map)
      : this(
          id: id,
          isParkingPath: map["isParkingPath"] as bool ?? false,
          points: (map["points"] as List<dynamic>)
                  .cast<GeoPoint>()
                  .map((geoPoint) => geoPoint.toLatLng())
                  .toList() ??
              [],
        );

  @override
  List<Object> get props => [id];
}
