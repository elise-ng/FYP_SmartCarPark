import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' hide LatLng;
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
import 'package:smart_car_park_app/models/car_park_floor.dart';
import 'package:smart_car_park_app/models/car_park_space.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarParkMapPage extends StatefulWidget {
  CarParkMapPage({
    key,
  }) : super(key: key);

  @override
  _CarParkMapPageState createState() => _CarParkMapPageState();
}

class _CarParkMapPageState extends State<CarParkMapPage> {
  static const FLOORS_COLLECTION = "carParkFloors";
  static const IOT_STATES_COLLECTION = "iotStates";

  List<CarParkFloor> carParkFloors = [];
  int currentFloorIndex = 0;

  ///Navigation
//  LatLng navigationOrigin = LatLng(22.338616, 114.263270);
//  CarParkSpace navigationTargetSpace;
//  Polyline navigatingPolyline;

  static final CameraPosition _ustParkingPosition = CameraPosition(
    bearing: 90.0,
    target: LatLng(22.3385, 114.26335),
    zoom: 21,
  );

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  void getData() async {
    QuerySnapshot floorsSnapshot =
    await Firestore.instance.collection(FLOORS_COLLECTION).getDocuments();
    this.carParkFloors = floorsSnapshot.documents
        .map((document) => CarParkFloor.fromDocument(document))
        .toList();
    this.carParkFloors.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    /// Init data and subscribe to updates
    Firestore.instance
        .collection(IOT_STATES_COLLECTION)
        .snapshots()
        .listen((snapshot) async {
      List<Future> changeFutures = [];

      for (DocumentChange change in snapshot.documentChanges) {
        if (!change.document.data.containsKey("position")) {
          continue;
        }

        CarParkSpace parkingSpace = CarParkSpace.fromDocument(change.document);
        CarParkFloor floor = this.carParkFloors.firstWhere(
                (floor) => floor.id == parkingSpace.floorId,
            orElse: () => null);

        /// Cannot find floor
        if (floor == null) {
          continue;
        }

        switch (change.type) {
          case DocumentChangeType.added:
            changeFutures.add(floor.addParkingSpace(
                context, parkingSpace, this.onParkingSpaceTap));
            break;
          case DocumentChangeType.modified:
            changeFutures.add(floor.updateParkingSpace(
                context, parkingSpace, this.onParkingSpaceTap));
            break;
          case DocumentChangeType.removed:
            changeFutures.add(floor.removeParkingSpace(context, parkingSpace));
            break;
        }
      }

      /// Wait for changes to complete and update UI
      setState(() {});
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
            compassEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            minMaxZoomPreference: MinMaxZoomPreference(20.0, 21.0),
            mapType: MapType.none,
            initialCameraPosition: _ustParkingPosition,
            cameraTargetBounds: CameraTargetBounds(LatLngBounds(northeast: LatLng(22.3385, 114.2636), southwest: LatLng(22.3382, 114.2630))),
            markers: {
              ...this._getMarkers(),
//              Marker(
//                markerId: MarkerId("navigation"),
//                position: this.navigationOrigin,
//                draggable: true,
//                onDragEnd: (latLng) {
//                  this.navigationOrigin = latLng;
//                  this.updateNavigationPath();
//                },
//              )
            },
            polygons: this._getPolygons(),
//            polylines: this._getPolylines(),
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
                      'assets/images/LG5.png',
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

  Set<Polygon> _getParkingSpaces(List<CarParkSpace> parkingSpaces) {
    return parkingSpaces.map((parkingSpace) {
      return Polygon(
        polygonId: PolygonId(parkingSpace.id),
        fillColor: parkingSpace.getStatusColor(),
        points: _getPolygonPoints(
          topLeft: parkingSpace.position,
          widthInMeter: parkingSpace.widthInMeters,
          heightInMeter: parkingSpace.heightInMeters,
          bearing: parkingSpace.bearing,
        ),
        strokeWidth: 1,
        consumeTapEvents: true,
        onTap: () => this.onParkingSpaceTap(parkingSpace),
      );
    }).toSet();
  }

  void onParkingSpaceTap(CarParkSpace space) {
//    this.navigationTargetSpace = space;
//    this.updateNavigationPath();
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

//  Set<Polyline> _getPolylines() {
//    if (this.navigatingPolyline == null) {
//      return {};
//    } else {
//      return {
//        this.navigatingPolyline,
//      };
//    }
//  }
//
//  void updateNavigationPath() async {
//    if (this.navigationOrigin == null || this.navigationTargetSpace == null) {
//      return;
//    }
//
//    List<LatLng> polylinePoints = await this.calculateParkingPath(
//        this.navigationOrigin, this.navigationTargetSpace);
//    print((polylinePoints));
//    setState(() {
//      this.navigatingPolyline = Polyline(
//        polylineId: PolylineId("navigation"),
//        color: Colors.deepOrange,
//        points: polylinePoints,
//        width: 3,
//      );
//    });
//  }
//
//  Future<List<LatLng>> calculateParkingPath(
//      LatLng originPoint, CarParkSpace space) async {
//    List<LatLng> navigationPathPoints = [space.center];
//    List<CarParkPath> availablePath =
//        List.from(this.carParkFloors[this.currentFloorIndex].paths);
//
//    CarParkPath lastUsedPath;
//    ProjectionInfo originPointOnNearestPathProjection = ParkingPathUtils.findNearestProjectionOnPath(
//      target: originPoint,
//      availablePaths: availablePath,
//      distanceRelativeToTarget: true,
//    );
//
//    do {
//      /// All projection of points on available paths, and it's distance to origin
//      ProjectionInfo projectionInfo =
//          ParkingPathUtils.findNearestProjectionOnPath(
//        origin: originPointOnNearestPathProjection.projection,
//        target: navigationPathPoints.last,
//        availablePaths: availablePath,
//        lastUsedPath: lastUsedPath,
//        distanceRelativeToTarget: navigationPathPoints.last == space.center,
//      );
//
//      /// Add the projection point to navigationPath, and remove the used path from available pool
//      navigationPathPoints.add(projectionInfo.projection);
//      lastUsedPath = projectionInfo.path;
//      availablePath.remove(projectionInfo.path);
//
//      /// If the last projection lands on the nearest path of the origin projection, end the navigation
//      if(lastUsedPath == originPointOnNearestPathProjection.path) {
//        navigationPathPoints.add(originPointOnNearestPathProjection.projection);
//        navigationPathPoints.add(originPoint);
//        break;
//      }
//
//      /// Used all available path
//      /// This case should not happen, but just as a safe guard
//      if (availablePath.isEmpty) {
//        navigationPathPoints.add(originPointOnNearestPathProjection.projection);
//        navigationPathPoints.add(originPoint);
//        break;
//      }
//    } while (navigationPathPoints.last != originPoint);
//
//    /// Flip the points since we calculate from the end back to start
//    return navigationPathPoints.reversed.toList();
//  }
}
