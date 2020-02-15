import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_car_park_app/models/car_park_path.dart';
import 'package:vector_math/vector_math.dart';

class ParkingPathUtils {
  static ProjectionInfo findNearestProjectionOnPath({
    LatLng origin,
    LatLng target,
    List<CarParkPath> availablePaths,

    /// Should NOT be inside availablePaths as well
    CarParkPath lastUsedPath,
    bool distanceRelativeToTarget = false,
  }) {
    /// Catch empty paths
    if (availablePaths.isEmpty) {
      throw Exception("Empty parking paths");
    }

    /// Copy list instead of referencing
    List<CarParkPath> paths = List.from(availablePaths);

    /// If we are parking to space, only choose parking paths
    if (distanceRelativeToTarget) {
      paths.removeWhere((path) => !path.isParkingPath);
    }

    /// The next path must intersect with the last used path
    if (lastUsedPath != null) {
      paths.removeWhere((path) => !intersect(path, lastUsedPath));
    }

    /// Calculate current last point's projection on paths, and the projection's distance to origin
    List<ProjectionInfo> projectionInfoList = [];
    for (CarParkPath path in paths) {
      LatLng projection = projectionOnPath(path, target);
      projectionInfoList.add(
        ProjectionInfo(
          path: path,
          projection: projection,
          distanceToOrigin:
              getLatLngDistance(projection, distanceRelativeToTarget ? target : origin), /// Find point nearest to parking target if is now parking
        ),
      );
    }

    /// Sort to get shortest distance to origin
    projectionInfoList
        .sort((a, b) => a.distanceToOrigin.compareTo(b.distanceToOrigin));
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

  /// Given three colinear points p, q, r, the function checks if
  /// point q lies on line segment 'pr'
  static bool onSegment(LatLng p, LatLng q, LatLng r) {
    if (q.latitude <= max(p.latitude, r.latitude) &&
        q.latitude >= min(p.latitude, r.latitude) &&
        q.longitude <= max(p.longitude, r.longitude) &&
        q.longitude >= min(p.longitude, r.longitude)) return true;

    return false;
  }

  /// To find orientation of ordered triplet (p, q, r).
  /// The function returns following values
  /// 0 --> p, q and r are colinear
  /// 1 --> Clockwise
  /// 2 --> Counterclockwise
  static int orientation(LatLng p, LatLng q, LatLng r) {
    // See https://www.geeksforgeeks.org/orientation-3-ordered-points/
    // for details of below formula.
    double val = (q.longitude - p.longitude) * (r.latitude - q.latitude) -
        (q.latitude - p.latitude) * (r.longitude - q.longitude);

    if (val == 0) return 0; // colinear

    return (val > 0) ? 1 : 2; // clock or counterclock wise
  }

  static intersect(CarParkPath a, CarParkPath b) {
    LatLng p1 = a.points[0];
    LatLng q1 = a.points[1];
    LatLng p2 = b.points[0];
    LatLng q2 = b.points[1];

    /// Find the four orientations needed for general and special cases
    int o1 = orientation(p1, q1, p2);
    int o2 = orientation(p1, q1, q2);
    int o3 = orientation(p2, q2, p1);
    int o4 = orientation(p2, q2, q1);

    /// General case
    if (o1 != o2 && o3 != o4) return true;

    /// Special Cases
    /// p1, q1 and p2 are colinear and p2 lies on segment p1q1
    if (o1 == 0 && onSegment(p1, p2, q1)) return true;

    /// p1, q1 and q2 are colinear and q2 lies on segment p1q1
    if (o2 == 0 && onSegment(p1, q2, q1)) return true;

    /// p2, q2 and p1 are colinear and p1 lies on segment p2q2
    if (o3 == 0 && onSegment(p2, p1, q2)) return true;

    /// p2, q2 and q1 are colinear and q1 lies on segment p2q2
    if (o4 == 0 && onSegment(p2, q1, q2)) return true;

    /// Doesn't fall in any of the above cases
    return false;
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
