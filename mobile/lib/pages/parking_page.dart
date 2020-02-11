
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' hide LatLng;
import 'package:smart_car_park_app/extensions/latlng_extensions.dart';
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

  static final CameraPosition _ustParkingPosition = CameraPosition(
    target: LatLng(22.338794, 114.262971),
    zoom: 20,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: _ustParkingPosition,
            onMapCreated: (GoogleMapController controller) {
              this._controller = controller;
            },
            polygons: {
              ...this._getPolygons(),
              ..._getParkingSpaces([
                ParkingSpace(
                  spaceID: "LG3-1",
                  latLng: LatLng(22.33865, 114.26308),
                ),
              ]),
            },
          ),
        ],
      ),
    );
  }

  Set<Polygon> _getPolygons() {
    return [
      Polygon(
        polygonId: PolygonId("carpark_bounds"),
        fillColor: Colors.blue[100],
        points: _getPolygonPoints(LatLng(22.33865, 114.26305),
            widthInMeter: 45, heightInMeter: 50),
        strokeWidth: 2,
      ),
    ].toSet();
  }

  Set<Polygon> _getParkingSpaces(List<ParkingSpace> parkingSpaces) {
    return parkingSpaces.map((parkingSpace) {
      return Polygon(
        consumeTapEvents: true,
        polygonId: PolygonId(parkingSpace.spaceID),
        fillColor: parkingSpace.getStatusColor(),
        points: _getPolygonPoints(parkingSpace.latLng),
        strokeWidth: 2,
      );
    }).toSet();
  }

  List<LatLng> _getPolygonPoints(LatLng topLeft,
      {double widthInMeter = 2, double heightInMeter = 5, double bearing = 0}) {
    Distance distance = Distance();
    LatLng bottomLeft = distance
        .offset(topLeft.toUtilsLatLng(), heightInMeter, 180 - bearing)
        .toGoogleLatLng();

    return [
      topLeft,
      bottomLeft,
      distance
          .offset(bottomLeft.toUtilsLatLng(), widthInMeter, 90 - bearing)
          .toGoogleLatLng(),
      distance
          .offset(topLeft.toUtilsLatLng(), widthInMeter, 90 - bearing)
          .toGoogleLatLng(),
      topLeft,
    ];
  }
}
