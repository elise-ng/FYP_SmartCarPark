import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_park_app/models/car_park_path.dart';
import 'package:vector_math/vector_math.dart';

class ParkingPathUtils {
  static ProjectionInfo findNearestProjectionOnPath(
      List<CarParkPath> paths, LatLng target,
      {bool isParkingToSpace = false}) {
    if (paths.isEmpty) {
      throw Exception("Empty parking paths");
    }

    if (isParkingToSpace) {
      paths.removeWhere((path) => !path.isParkingPath);
    }
    List<ProjectionInfo> projectionInfoList = [];
    for (CarParkPath path in paths) {
      projectionInfoList.add(projectionOnPath(path, target));
    }
    projectionInfoList.sort((a, b) => a.distance.compareTo(b.distance));
    return projectionInfoList.first;
  }

  static ProjectionInfo projectionOnPath(CarParkPath path, LatLng point) {
    LatLng a = path.points[0];
    LatLng b = path.points[1];
    Vector2 vec1 = Vector2(a.latitude, a.longitude);
    Vector2 vec2 = Vector2(b.latitude, b.longitude);
    Vector2 vecTarget = Vector2(point.latitude, point.longitude);

    double l2 = vec1.distanceToSquared(vec2);
    double t = max(0, min(1, (vecTarget - vec1).dot(vec2 - vec1)) / l2);
    Vector2 projectionVec = vec1 + (vec2 - vec1) * t;
    LatLng projection = LatLng(projectionVec.x, projectionVec.y);
    return ProjectionInfo(
      path: path,
      projection: projection,
      distance: projectionVec.distanceTo(vecTarget),
    );
  }

  static getLatLngDistance(LatLng a, LatLng b) {
    return sqrt(pow(a.latitude - b.latitude, 2) + pow(a.longitude - b.longitude, 2));
  }
}

class ProjectionInfo {
  CarParkPath path;
  LatLng projection;
  double distance;

  ProjectionInfo({
    this.path,
    this.projection,
    this.distance,
  });
}
