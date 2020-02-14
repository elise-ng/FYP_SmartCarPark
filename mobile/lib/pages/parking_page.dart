import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' hide LatLng;
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
import 'package:smart_car_park_app/models/car_park_floor.dart';
import 'package:smart_car_park_app/models/parking_space.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingPage extends StatefulWidget {
  ParkingPage({
    key,
  }) : super(key: key);

  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  static const FLOORS_COLLECTION = "carParkFloors";
  static const IOT_STATES_COLLECTION = "iotStates";

  GoogleMapController _controller;

  List<CarParkFloor> carParkFloors = [];
  int currentFloorIndex = 0;

  static final CameraPosition _ustParkingPosition = CameraPosition(
    target: LatLng(22.338616, 114.263270),
    zoom: 19.7,
  );

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  void getData() async {
    QuerySnapshot floorsSnapshot = await Firestore.instance.collection(FLOORS_COLLECTION).getDocuments();
    this.carParkFloors = floorsSnapshot.documents
        .map((document) => CarParkFloor.fromDocument(document))
        .toList();
    this.carParkFloors.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    /// Init data and subscribe to updates
    Firestore.instance
        .collection("iotStates")
        .snapshots()
        .listen((snapshot) async {
      List<Future> changeFutures = [];

      for (DocumentChange change in snapshot.documentChanges) {
        if(!change.document.data.containsKey("position")) {
          continue;
        }

        ParkingSpace parkingSpace = ParkingSpace.fromDocument(change.document);
        CarParkFloor floor = this.carParkFloors.firstWhere(
            (floor) => floor.id == parkingSpace.floorId,
            orElse: () => null);

        /// Cannot find floor
        if (floor == null) {
          continue;
        }

        switch (change.type) {
          case DocumentChangeType.added:
            changeFutures.add(floor.addParkingSpace(context, parkingSpace));
            break;
          case DocumentChangeType.modified:
            changeFutures.add(floor.updateParkingSpace(context, parkingSpace));
            break;
          case DocumentChangeType.removed:
            changeFutures.add(floor.removeParkingSpace(context, parkingSpace));
            break;
        }
      }

      /// Wait for changes to complete and update UI
      await Future.wait(changeFutures);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            minMaxZoomPreference: MinMaxZoomPreference(19.0, 26.0),
            mapType: MapType.normal,
            initialCameraPosition: _ustParkingPosition,
            onMapCreated: (GoogleMapController controller) {
              this._controller = controller;
            },
            markers: this._getMarkers(),
            polygons: this._getPolygons(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.0,
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

  /// Handles markers
  /// Marker generation logic are located inside CarParkFloor class
  Set<Marker> _getMarkers() {
    if (this.carParkFloors.isEmpty ||
        this.carParkFloors.any((floor) => floor.parkingSpaceMarkers.isEmpty)) {
      return {};
    } else {
      return this
          .carParkFloors[this.currentFloorIndex]
          .parkingSpaceMarkers
          .toSet();
    }
  }

  /// Handles polygons
  Set<Polygon> _getPolygons() {
    if (this.carParkFloors.isEmpty) {
      return {};
    } else {
      return {
        ...this._getFloorPolygon(this.carParkFloors[this.currentFloorIndex]),
        ...this._getParkingSpaces(
            (this.carParkFloors[this.currentFloorIndex]).parkingSpaces),
      };
    }
  }

  Set<Polygon> _getFloorPolygon(CarParkFloor floor) {
    return [
      Polygon(
        polygonId: PolygonId("${floor.id}_floor"),
        fillColor: Colors.blue[100],
        points: floor.points,
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