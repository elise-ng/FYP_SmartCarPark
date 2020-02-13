import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';

class CarParkFloor {

  final String id;
  final String name;
  final int zIndex;
  final List<LatLng> points;
  final List<List<LatLng>> paths;

  CarParkFloor({
    this.id,
    this.name,
    this.zIndex = 0,
    this.points,
    this.paths,
  });

  CarParkFloor.fromDocument(DocumentSnapshot document): this(
    id: document.documentID,
    name: (document.data["name"] as String) ?? document.documentID.toUpperCase(),
    zIndex: document.data["zIndex"] ?? 0,
    points: document.data["point"] ?? [],
    paths: (document.data["paths"] as Map<String, List<GeoPoint>>).values.map((geoPoints) => geoPoints.map((geoPoint) => geoPoint.toLatLng())) ?? [],
  );
}
