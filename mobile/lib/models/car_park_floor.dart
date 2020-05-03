import 'dart:async';
import 'dart:typed_data';

import 'package:bordered_text/bordered_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
import 'package:smart_car_park_app/models/car_park_path.dart';
import 'package:smart_car_park_app/utils/marker_generator.dart';
import 'package:smart_car_park_app/models/car_park_space.dart';

class CarParkFloor extends Equatable {
  final String id;
  final String name;
  final int zIndex;
  final List<LatLng> points;
  final List<CarParkPath> paths;

  List<CarParkSpace> parkingSpaces = [];
  List<Marker> parkingSpaceMarkers = [];

  CarParkFloor({
    this.id,
    this.name,
    this.zIndex = 0,
    this.points,
    this.paths,
  });

  CarParkFloor.fromDocument(DocumentSnapshot document)
      : this(
          id: document.documentID,
          name: (document.data["name"] as String) ??
              document.documentID.toUpperCase(),
          zIndex: document.data["zIndex"] ?? 0,
          points: (document.data["points"] as List<dynamic>)
                  .cast<GeoPoint>()
                  .map((geoPoint) => geoPoint.toLatLng())
                  .toList() ??
              [],
          paths: (document.data["paths"] as List<dynamic>)
                  .cast<Map<dynamic, dynamic>>()
                  .asMap()
                  .entries
                  .map((entry) => CarParkPath.fromMap(
                      "path-${document.documentID}-${entry.key}", entry.value))
                  .toList() ??
              [],
        );

  Future<void> setParkingSpaces(
      BuildContext context, List<CarParkSpace> parkingSpaces, Function(CarParkSpace) markerTapCallback) async {
    this.parkingSpaces = parkingSpaces;

    /// Generate markers
    Completer completer = Completer();
    MarkerGenerator(markerWidgets(this.parkingSpaces), (bitmaps) {
      this.parkingSpaceMarkers =
          this.mapBitmapsToMarkers(this.parkingSpaces, bitmaps, markerTapCallback);
      completer.complete();
    }).generate(context);

    await completer.future;
  }

  Future<void> addParkingSpace(
      BuildContext context, CarParkSpace parkingSpace, Function(CarParkSpace) markerTapCallback) async {
    /// Generate marker
    Completer completer = Completer();
    MarkerGenerator(markerWidgets([parkingSpace]), (bitmaps) {
      this.parkingSpaces.add(parkingSpace);
      this
          .parkingSpaceMarkers
          .add(this.mapBitmapsToMarkers([parkingSpace], bitmaps, markerTapCallback).first);
      completer.complete();
    }).generate(context);

    await completer.future;
  }

  /// Assuming position and name unchanged
  Future<bool> updateParkingSpace(
      BuildContext context, CarParkSpace parkingSpace, Function(CarParkSpace) markerTapCallback,
      {bool updateMarker = false}) async {
    int index = this.parkingSpaces.indexOf(parkingSpace);
    if (index == -1) {
      /// Cannot find existing parking space, skipping
      return false;
    }

    if (updateMarker) {
      /// Generate and replace marker
      Completer completer = Completer();
      MarkerGenerator(markerWidgets([parkingSpace]), (bitmaps) {
        this.parkingSpaces[index] = parkingSpace;
        int markerIndex = this
            .parkingSpaceMarkers
            .indexWhere((marker) => marker.markerId.value == parkingSpace.id);
        this.parkingSpaceMarkers[markerIndex] =
            this.mapBitmapsToMarkers([parkingSpace], bitmaps, markerTapCallback).first;
        completer.complete();
      }).generate(context);

      await completer.future;
      return true;
    } else {
      this.parkingSpaces[index] = parkingSpace;
      return true;
    }
  }

  Future<void> removeParkingSpace(
      BuildContext context, CarParkSpace parkingSpace) async {
    this.parkingSpaces.remove(parkingSpace);
    this
        .parkingSpaceMarkers
        .removeWhere((marker) => marker.markerId.value == parkingSpace.id);
  }

  List<Widget> markerWidgets(List<CarParkSpace> parkingSpaces) {
    return parkingSpaces.map((space) => _getMarkerWidget(space)).toList();
  }

  Widget _getMarkerWidget(CarParkSpace parkingSpace) {
    return BorderedText(
      strokeWidth: 2.0,
      strokeColor: Colors.white,
      child: Text(
        parkingSpace.displayName ?? parkingSpace.id.toUpperCase(),
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Marker> mapBitmapsToMarkers(
      List<CarParkSpace> parkingSpaces, List<Uint8List> bitmaps, Function(CarParkSpace) tapCallback) {
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
          consumeTapEvents: true,
          onTap: () => tapCallback(parkingSpace),
        ),
      );
    });
    return markersList;
  }

  @override
  List<Object> get props => [id];
}
