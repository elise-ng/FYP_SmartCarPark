import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as Utils;

extension GoogleConversion on Utils.LatLng {
  LatLng toGoogleLatLng() =>  LatLng(this.latitude, this.longitude);
}

extension UtilsConversion on LatLng {
  Utils.LatLng toUtilsLatLng() => Utils.LatLng(double.parse(this.latitude.toStringAsFixed(7)), double.parse(this.longitude.toStringAsFixed(7)));
}

extension FireStoreConversion on GeoPoint {
  LatLng toLatLng() => LatLng(this.latitude, this.longitude);
}

extension GeoPointConversion on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(double.parse(this.latitude.toStringAsFixed(7)), double.parse(this.longitude.toStringAsFixed(7)));
}