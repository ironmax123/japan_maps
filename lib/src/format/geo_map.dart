import 'dart:convert';
import 'dart:math';

import 'package:japan_maps/src/model/lat_lng.dart';

/// GeoJSON 全体を地図用ポリゴン群に変換
List<List<LatLng>> geoJsonToMap(String geoJsonString) {
  final Map<String, dynamic> geo = jsonDecode(geoJsonString);

  final List<List<LatLng>> polygons = [];

  for (final feature in geo['features']) {
    final geometry = feature['geometry'];
    final type = geometry['type'];
    final coords = geometry['coordinates'];

    if (type == 'Polygon') {
      polygons.addAll(_parsePolygon(coords));
    } else if (type == 'MultiPolygon') {
      for (final polygon in coords) {
        polygons.addAll(_parsePolygon(polygon));
      }
    }
  }

  return _normalize(polygons);
}

/// Polygon パース
List<List<LatLng>> _parsePolygon(List polygonCoords) {
  final List<List<LatLng>> result = [];

  for (final ring in polygonCoords) {
    final List<LatLng> path = [];

    for (final point in ring) {
      final lon = point[0].toDouble();
      final lat = point[1].toDouble();
      path.add(LatLng(latitude: lat, longitude: lon));
    }

    result.add(path);
  }

  return result;
}

///正規化（地図座標化）
List<List<LatLng>> _normalize(List<List<LatLng>> polygons) {
  double minLat = double.infinity;
  double maxLat = -double.infinity;
  double minLon = double.infinity;
  double maxLon = -double.infinity;

  for (final poly in polygons) {
    for (final p in poly) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLon = min(minLon, p.longitude);
      maxLon = max(maxLon, p.longitude);
    }
  }

  final latRange = maxLat - minLat;
  final lonRange = maxLon - minLon;

  return polygons.map((poly) {
    return poly.map((p) {
      final x = ((p.longitude - minLon) / lonRange) * 2 - 1;
      final y = -(((p.latitude - minLat) / latRange) * 2 - 1);
      return LatLng(latitude: y, longitude: x);
    }).toList();
  }).toList();
}
