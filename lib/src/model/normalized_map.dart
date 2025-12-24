import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:japan_maps/src/model/map_bounds.dart';

class NormalizedMap {
  final List<List<LatLng>> polygons; // normalized (-1..1)
  final double minLat, maxLat, minLon, maxLon; // raw lat/lon bounds

  NormalizedMap({
    required this.polygons,
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
  });
}

class NormalizedMapData {
  final List<List<LatLng>> polygons;
  final MapBounds bounds;

  const NormalizedMapData({required this.polygons, required this.bounds});
}
