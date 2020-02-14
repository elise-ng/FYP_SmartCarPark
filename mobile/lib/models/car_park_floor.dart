import 'dart:async';
import 'dart:typed_data';

import 'package:bordered_text/bordered_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
import 'package:smart_car_park_app/marker_generator.dart';
import 'package:smart_car_park_app/models/parking_space.dart';

class CarParkFloor {

  final String id;
  final String name;
  final int zIndex;
  final List<LatLng> points;
  final List<List<LatLng>> paths;

  List<ParkingSpace> parkingSpaces = [];
  List<Marker> parkingSpaceMarkers = [];

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
    points: (document.data["points"] as List<dynamic>).cast<GeoPoint>().map((geoPoint) => geoPoint.toLatLng()).toList() ?? [],
    paths: (document.data["paths"] as Map<dynamic, dynamic>).values.cast<List<dynamic>>().map((geoPoints) => geoPoints.cast<GeoPoint>().map((geoPoint) => geoPoint.toLatLng()).toList()).toList() ?? [],
  );

  Future<void> setParkingSpaces(BuildContext context, List<ParkingSpace> parkingSpaces) async {
    this.parkingSpaces = parkingSpaces;

    /// Generate layer markers
    Completer completer = Completer();
    MarkerGenerator(markerWidgets(this.parkingSpaces), (bitmaps) {
      this.parkingSpaceMarkers = this.mapBitmapsToMarkers(this.parkingSpaces, bitmaps);
      completer.complete();
    }).generate(context);

    await completer.future;
  }

  List<Widget> markerWidgets(List<ParkingSpace> parkingSpaces) {
    return parkingSpaces.map((space) => _getMarkerWidget(space)).toList();
  }

  Widget _getMarkerWidget(ParkingSpace parkingSpace) {
    return BorderedText(
      strokeWidth: 2.0,
      strokeColor: Colors.white,
      child: Text(
        parkingSpace.id.toUpperCase(),
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Marker> mapBitmapsToMarkers(
      List<ParkingSpace> parkingSpaces, List<Uint8List> bitmaps) {
    List<Marker> markersList = [];
    bitmaps.asMap().forEach((i, bmp) {
      final parkingSpace = parkingSpaces[i];
      markersList.add(
        Marker(
          anchor: Offset(0.5, 0.5),
          rotation: 90,
          markerId: MarkerId(parkingSpace.id),
          position: parkingSpace.center,
          flat: true,
          icon: BitmapDescriptor.fromBytes(bmp),
        ),
      );
    });
    return markersList;
  }
}
