import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_park_app/models/car_park_path.dart';
import 'package:vector_math/vector_math.dart';

class ParkingPathUtils {
  static ProjectionInfo findNearestProjectionOnPath({
    LatLng origin,
    LatLng target,
    List<CarParkPath> availablePaths,
    bool isParkingToSpace = false,
  }) {
    /// Catch empty paths
    if (availablePaths.isEmpty) {
      throw Exception("Empty parking paths");
    }

    /// Copy list instead of referencing
    List<CarParkPath> paths = List.from(availablePaths);

    /// If we are parking to space, only choose parking paths
    if (isParkingToSpace) {
      paths.removeWhere((path) => !path.isParkingPath);
    }

    /// Calculate current last point's projection on paths, and the projection's distance to origin
    List<ProjectionInfo> projectionInfoList = [];
    for (CarParkPath path in paths) {
      LatLng projection = projectionOnPath(path, target);
      projectionInfoList.add(
        ProjectionInfo(
          path: path,
          projection: projection,
          distanceToOrigin: getLatLngDistance(projection, origin),
        ),
      );
    }

    /// Sort to get shortest distance to origin
    projectionInfoList.sort((a, b) => a.distanceToOrigin.compareTo(b.distanceToOrigin));
    return projectionInfoList.first;
  }

  static LatLng projectionOnPath(CarParkPath path, LatLng point) {
    LatLng a = path.points[0];
    LatLng b = path.points[1];
    Vector2 vec1 = Vector2(a.latitude, a.longitude);
    Vector2 vec2 = Vector2(b.latitude, b.longitude);
    Vector2 vecTarget = Vector2(point.latitude, point.longitude);

    double l2 = vec1.distanceToSquared(vec2);
    double t = max(0, min(1, (vecTarget - vec1).dot(vec2 - vec1)) / l2);
    Vector2 projectionVec = vec1 + (vec2 - vec1) * t;
    return LatLng(projectionVec.x, projectionVec.y);
  }

  static getLatLngDistance(LatLng a, LatLng b) {
    return sqrt(
        pow(a.latitude - b.latitude, 2) + pow(a.longitude - b.longitude, 2));
  }
}

class ProjectionInfo {
  CarParkPath path;
  LatLng projection;
  double distanceToOrigin;

  ProjectionInfo({
    this.path,
    this.projection,
    this.distanceToOrigin,
  });
}
