import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as Utils;

extension GoogleConversion on Utils.LatLng {
  LatLng toGoogleLatLng() {
    return LatLng(this.latitude, this.longitude);
  }
}

extension UtilsConversion on LatLng {
  Utils.LatLng toUtilsLatLng() {
    return Utils.LatLng(this.latitude, this.longitude);
  }
}
