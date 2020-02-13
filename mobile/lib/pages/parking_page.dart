import 'dart:typed_data';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' hide LatLng;
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
import 'package:smart_car_park_app/marker_generator.dart';
import 'package:smart_car_park_app/models/parking_space.dart';

class ParkingPage extends StatefulWidget {
  ParkingPage({
    key,
  }) : super(key: key);

  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  GoogleMapController _controller;
  List<ParkingSpace> parkingSpaces = [
    ParkingSpace(
      id: "LG5-1",
      latitude: 22.338610,
      longitude: 114.263216,
    ),
    ParkingSpace(
      id: "LG5-2",
      latitude: 22.338610,
      longitude: 114.263260,
    ),
    ParkingSpace(
      id: "LG5-3",
      latitude: 22.338610,
      longitude: 114.263283,
    ),
    ParkingSpace(
      id: "LG5-4",
      latitude: 22.338610,
      longitude: 114.263320,
    ),
    ParkingSpace(
      id: "LG5-5",
      latitude: 22.338610,
      longitude: 114.263343,
    ),

    ParkingSpace(
      id: "LG5-6",
      latitude: 22.338610,
      longitude: 114.263380,
    ),
    ParkingSpace(
      id: "LG5-7",
      latitude: 22.338610,
      longitude: 114.263403,
    ),

    ParkingSpace(
      id: "LG5-8",
      latitude: 22.338610,
      longitude: 114.263444,
    ),
    ParkingSpace(
      id: "LG5-9",
      latitude: 22.338610,
      longitude: 114.263468,
    ),
    ParkingSpace(
      id: "LG5-10",
      latitude: 22.338610,
      longitude: 114.263506,
    ),
    ParkingSpace(
      id: "LG5-11",
      latitude: 22.338610,
      longitude: 114.263530,
    ),
    ParkingSpace(
      id: "LG5-12",
      latitude: 22.338524,
      longitude: 114.263194,
    ),
    ParkingSpace(
      id: "LG5-13",
      latitude: 22.338524,
      longitude: 114.263216,
    ),
    ParkingSpace(
      id: "LG5-14",
      latitude: 22.338524,
      longitude: 114.263283,
    ),
    ParkingSpace(
      id: "LG5-15",
      latitude: 22.338524,
      longitude: 114.263320,
    ),
    ParkingSpace(
      id: "LG5-16",
      latitude: 22.338524,
      longitude: 114.263343,
    ),

    ParkingSpace(
      id: "LG5-17",
      latitude: 22.338524,
      longitude: 114.263380,
    ),
    ParkingSpace(
      id: "LG5-18",
      latitude: 22.338524,
      longitude: 114.263403,
    ),

    ParkingSpace(
      id: "LG5-19",
      latitude: 22.338524,
      longitude: 114.263444,
    ),

    ParkingSpace(
      id: "LG5-20",
      latitude: 22.338524,
      longitude: 114.263475,
    ),

    ParkingSpace(
      id: "LG5-21",
      latitude: 22.338524,
      longitude: 114.263506,
    ),
    ParkingSpace(
      id: "LG5-22",
      latitude: 22.338480,
      longitude: 114.263194,
    ),
    ParkingSpace(
      id: "LG5-23",
      latitude: 22.338480,
      longitude: 114.263216,
    ),
    ParkingSpace(
      id: "LG5-24",
      latitude: 22.338480,
      longitude: 114.263283,
    ),
    ParkingSpace(
      id: "LG5-25",
      latitude: 22.338480,
      longitude: 114.263320,
    ),
    ParkingSpace(
      id: "LG5-26",
      latitude: 22.338480,
      longitude: 114.263343,
    ),

    ParkingSpace(
      id: "LG5-27",
      latitude: 22.338480,
      longitude: 114.263380,
    ),
    ParkingSpace(
      id: "LG5-28",
      latitude: 22.338480,
      longitude: 114.263403,
    ),

    ParkingSpace(
      id: "LG5-29",
      latitude: 22.338480,
      longitude: 114.263444,
    ),

    ParkingSpace(
      id: "LG5-30",
      latitude: 22.338480,
      longitude: 114.263475,
    ),

    ParkingSpace(
      id: "LG5-31",
      latitude: 22.338480,
      longitude: 114.263506,
    ),

    ParkingSpace(
      id: "LG5-32",
      latitude: 22.338394,
      longitude: 114.263194,
    ),
    ParkingSpace(
      id: "LG5-33",
      latitude: 22.338394,
      longitude: 114.263216,
    ),
    ParkingSpace(
      id: "LG5-34",
      latitude: 22.338394,
      longitude: 114.263283,
    ),
    ParkingSpace(
      id: "LG5-35",
      latitude: 22.338394,
      longitude: 114.263320,
    ),
    ParkingSpace(
      id: "LG5-36",
      latitude: 22.338394,
      longitude: 114.263343,
    ),

    ParkingSpace(
      id: "LG5-37",
      latitude: 22.338394,
      longitude: 114.263380,
    ),
    ParkingSpace(
      id: "LG5-38",
      latitude: 22.338394,
      longitude: 114.263403,
    ),

    ParkingSpace(
      id: "LG5-39",
      latitude: 22.338394,
      longitude: 114.263444,
    ),

    ParkingSpace(
      id: "LG5-40",
      latitude: 22.338394,
      longitude: 114.263475,
    ),

    ParkingSpace(
      id: "LG5-41",
      latitude: 22.338394,
      longitude: 114.263506,
    ),
    ParkingSpace(
      id: "LG5-42",
      latitude: 22.338350,
      longitude: 114.263194,
    ),
    ParkingSpace(
      id: "LG5-43",
      latitude: 22.338350,
      longitude: 114.263216,
    ),
    ParkingSpace(
      id: "LG5-44",
      latitude: 22.338350,
      longitude: 114.263283,
    ),
    ParkingSpace(
      id: "LG5-45",
      latitude: 22.338350,
      longitude: 114.263320,
    ),
    ParkingSpace(
      id: "LG5-46",
      latitude: 22.338350,
      longitude: 114.263343,
    ),

    ParkingSpace(
      id: "LG5-47",
      latitude: 22.338350,
      longitude: 114.263380,
    ),
    ParkingSpace(
      id: "LG5-48",
      latitude: 22.338350,
      longitude: 114.263403,
    ),

    ParkingSpace(
      id: "LG5-49",
      latitude: 22.338350,
      longitude: 114.263444,
    ),

    ParkingSpace(
      id: "LG5-50",
      latitude: 22.338350,
      longitude: 114.263475,
    ),

    ParkingSpace(
      id: "LG5-51",
      latitude: 22.338350,
      longitude: 114.263506,
    ),
    ParkingSpace(
      id: "LG5-52",
      latitude: 22.338264,
      longitude: 114.263283,
    ),
    ParkingSpace(
      id: "LG5-53",
      latitude: 22.338264,
      longitude: 114.263320,
    ),
    ParkingSpace(
      id: "LG5-54",
      latitude: 22.338264,
      longitude: 114.263343,
    ),

    ParkingSpace(
      id: "LG5-55",
      latitude: 22.338264,
      longitude: 114.263380,
    ),
    ParkingSpace(
      id: "LG5-56",
      latitude: 22.338264,
      longitude: 114.263403,
    ),

    ParkingSpace(
      id: "LG5-57",
      latitude: 22.338264,
      longitude: 114.263444,
    ),
    ParkingSpace(
      id: "LG5-58",
      latitude: 22.338264,
      longitude: 114.263468,
    ),
  ];
  List<Marker> parkingSpaceMarkers = [];

  static final CameraPosition _ustParkingPosition = CameraPosition(
    target: LatLng(22.338616, 114.263270),
    zoom: 19.7,
  );

  @override
  void initState() {
    super.initState();
    MarkerGenerator(markerWidgets(this.parkingSpaces), (bitmaps) {
      setState(() {
        this.parkingSpaceMarkers =
            this.mapBitmapsToMarkers(this.parkingSpaces, bitmaps);
      });
    }).generate(context);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            minMaxZoomPreference: MinMaxZoomPreference(18.0, 26.0),
            mapType: MapType.normal,
            initialCameraPosition: _ustParkingPosition,
            onMapCreated: (GoogleMapController controller) {
              this._controller = controller;
            },
            markers: {
              ...this.parkingSpaceMarkers.toSet(),
            },
            polygons: {
              ...this._getPolygons(),
              ..._getParkingSpaces(this.parkingSpaces),
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Image.asset(
                      'assets/LG5.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Markers
  List<Widget> markerWidgets(List<ParkingSpace> parkingSpaces) {
    return parkingSpaces.map((space) => _getMarkerWidget(space)).toList();
  }

  Widget _getMarkerWidget(ParkingSpace parkingSpace) {
    return BorderedText(
      strokeWidth: 2.0,
      strokeColor: Colors.white,
      child: Text(
        parkingSpace.id,
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

  /// Polygons
  Set<Polygon> _getPolygons() {
    return [
      Polygon(
        polygonId: PolygonId("LG5_carpark_bounds"),
        fillColor: Colors.blue[100],
        points: [
          LatLng(22.338610, 114.263130),
          LatLng(22.338610, 114.263565),
          LatLng(22.338205, 114.263565),
          LatLng(22.338205, 114.263260),
          LatLng(22.338300, 114.263180),
          LatLng(22.338510, 114.263180),
          LatLng(22.338510, 114.263080),
          LatLng(22.338570, 114.263080),
          LatLng(22.338570, 114.263130),
          LatLng(22.338610, 114.263130),
        ],
        strokeWidth: 2,
      ),
    ].toSet();
  }

  Set<Polygon> _getParkingSpaces(List<ParkingSpace> parkingSpaces) {
    return parkingSpaces.map((parkingSpace) {
      return Polygon(
        consumeTapEvents: true,
        polygonId: PolygonId(parkingSpace.id),
        fillColor: parkingSpace.getStatusColor(),
        points: _getPolygonPoints(
          topLeft: parkingSpace.position,
          widthInMeter: parkingSpace.widthInMeters,
          heightInMeter: parkingSpace.heightInMeters,
          bearing: parkingSpace.bearing,
        ),
        strokeWidth: 1,
      );
    }).toSet();
  }

  List<LatLng> _getPolygonPoints({
    LatLng topLeft,
    double widthInMeter,
    double heightInMeter,
    double bearing,
  }) {
    Distance distance = Distance();
    LatLng topRight = distance
        .offset(topLeft.toUtilsLatLng(), widthInMeter, 90 - bearing)
        .toGoogleLatLng();

    return [
      topLeft,
      topRight,
      distance
          .offset(topRight.toUtilsLatLng(), heightInMeter, 180 - bearing)
          .toGoogleLatLng(),
      distance
          .offset(topLeft.toUtilsLatLng(), heightInMeter, 180 - bearing)
          .toGoogleLatLng(),
      topLeft,
    ];
  }
}
