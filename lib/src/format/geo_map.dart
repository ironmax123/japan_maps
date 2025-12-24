import 'dart:convert';
import 'dart:math';

import 'package:japan_maps/src/format/mercator_projection.dart';
import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:japan_maps/src/model/map_bounds.dart';
import 'package:japan_maps/src/model/normalized_map.dart';

/// GeoJSON 全体を地図用ポリゴン群に変換

NormalizedMapData geoJsonToMercatorMap(String geoJsonString) {
  final Map<String, dynamic> geo = jsonDecode(geoJsonString);
  final List<List<Point<double>>> projected = [];

  double minX = double.infinity;
  double maxX = -double.infinity;
  double minY = double.infinity;
  double maxY = -double.infinity;

  for (final feature in geo['features']) {
    final geometry = feature['geometry'];
    final type = geometry['type'];
    final coords = geometry['coordinates'];

    if (type == 'Polygon') {
      _parsePolygon(coords, projected, (x, y) {
        minX = min(minX, x);
        maxX = max(maxX, x);
        minY = min(minY, y);
        maxY = max(maxY, y);
      });
    } else if (type == 'MultiPolygon') {
      for (final poly in coords) {
        _parsePolygon(poly, projected, (x, y) {
          minX = min(minX, x);
          maxX = max(maxX, x);
          minY = min(minY, y);
          maxY = max(maxY, y);
        });
      }
    }
  }

  final dx = maxX - minX;
  final dy = maxY - minY;

  final normalized = projected.map((poly) {
    return poly.map((p) {
      final nx = ((p.x - minX) / dx) * 2 - 1;
      final ny = -(((p.y - minY) / dy) * 2 - 1);
      return LatLng(latitude: ny, longitude: nx);
    }).toList();
  }).toList();

  return NormalizedMapData(
    polygons: normalized,
    bounds: MapBounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY),
  );
}

void _parsePolygon(
  List polygonCoords,
  List<List<Point<double>>> out,
  void Function(double x, double y) onPoint,
) {
  for (final ring in polygonCoords) {
    final List<Point<double>> path = [];

    for (final coord in ring) {
      final lon = coord[0].toDouble();
      final lat = coord[1].toDouble();

      final x = MercatorProjection.projectX(lon);
      final y = MercatorProjection.projectY(lat);

      onPoint(x, y);
      path.add(Point(x, y));
    }

    out.add(path);
  }
}

/// raw lat/lon center -> normalized (-1..1) center
LatLng normalizeCenter(LatLng rawCenter, NormalizedMapData map) {
  final px = MercatorProjection.projectX(rawCenter.longitude);
  final py = MercatorProjection.projectY(rawCenter.latitude);

  final dx = map.bounds.maxX - map.bounds.minX;
  final dy = map.bounds.maxY - map.bounds.minY;

  final nx = ((px - map.bounds.minX) / dx) * 2 - 1;
  final ny = -(((py - map.bounds.minY) / dy) * 2 - 1);

  return LatLng(latitude: ny, longitude: nx);
}
