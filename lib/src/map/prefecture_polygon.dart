import 'package:japan_maps/src/model/lat_lng.dart';

class PrefecturePolygon {
  final String key; // e.g. "tokyo", "osaka"
  final List<LatLng> polygon;

  const PrefecturePolygon({required this.key, required this.polygon});
}

bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  bool inside = false;

  for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i].longitude;
    final yi = polygon[i].latitude;
    final xj = polygon[j].longitude;
    final yj = polygon[j].latitude;

    final intersect =
        ((yi > point.latitude) != (yj > point.latitude)) &&
        (point.longitude <
            (xj - xi) * (point.latitude - yi) / (yj - yi + 0.0) + xi);

    if (intersect) inside = !inside;
  }

  return inside;
}

String? detectPrefecture(LatLng tapPoint, List<PrefecturePolygon> prefectures) {
  for (final pref in prefectures) {
    if (isPointInPolygon(tapPoint, pref.polygon)) {
      return pref.key;
    }
  }
  return null;
}
