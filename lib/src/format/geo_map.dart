import 'dart:convert';
import 'dart:math';

import 'package:japan_maps/src/format/mercator_projection.dart';
import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:japan_maps/src/model/map_bounds.dart';
import 'package:japan_maps/src/model/normalized_map.dart';

/// GeoJSON 全体を地図用ポリゴン群に変換
NormalizedMapData geoJsonToMercatorMap(String geoJsonString) {
  final Map<String, dynamic> geo = jsonDecode(geoJsonString);
  double minX = double.infinity;
  double maxX = -double.infinity;
  double minY = double.infinity;
  double maxY = -double.infinity;

  final List<MapPolygon> normalizedPolygons = [];

  for (final feature in geo['features']) {
    final geometry = feature['geometry'];
    if (geometry == null) continue;

    final type = geometry['type'];
    final coords = geometry['coordinates'];

    if (type == 'Polygon') {
      _scanBounds(coords, (x, y) {
        minX = min(minX, x);
        maxX = max(maxX, x);
        minY = min(minY, y);
        maxY = max(maxY, y);
      });
    } else if (type == 'MultiPolygon') {
      for (final poly in coords) {
        _scanBounds(poly, (x, y) {
          minX = min(minX, x);
          maxX = max(maxX, x);
          minY = min(minY, y);
          maxY = max(maxY, y);
        });
      }
    }
  }

  // Re-iterate to normalize, but this time we need to associate with properties.
  // Ideally we should have stored them together. Let's refactor the loop slightly above or just do it in one pass if possible.
  // Actually, the previous logic was accumulating ALL polygons into `projected`.
  // To support properties, we need to keep polygons grouped by feature or just list of polygons with properties.
  // `NormalizedMapData` expects a flat list of polygons? No, `MapPolygon` has properties.
  // So if a feature is MultiPolygon, do we create multiple `MapPolygon`s with same properties? Yes, that's easiest.

  // Let's restart the loop logic to be cleaner.
  minX = double.infinity;
  maxX = -double.infinity;
  minY = double.infinity;
  maxY = -double.infinity;

  // First pass: Calculate bounds
  for (final feature in geo['features']) {
    final geometry = feature['geometry'];
    if (geometry == null) continue;
    final type = geometry['type'];
    final coords = geometry['coordinates'];

    if (type == 'Polygon') {
      _scanBounds(coords, (x, y) {
        minX = min(minX, x);
        maxX = max(maxX, x);
        minY = min(minY, y);
        maxY = max(maxY, y);
      });
    } else if (type == 'MultiPolygon') {
      for (final poly in coords) {
        _scanBounds(poly, (x, y) {
          minX = min(minX, x);
          maxX = max(maxX, x);
          minY = min(minY, y);
          maxY = max(maxY, y);
        });
      }
    }
  }

  final width = maxX - minX;
  final height = maxY - minY;

  // Second pass: Create MapPolygons
  for (final feature in geo['features']) {
    final geometry = feature['geometry'];
    if (geometry == null) continue;
    final type = geometry['type'];
    final coords = geometry['coordinates'];
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};

    final List<List<Point<double>>> featureProjectedPolys = [];

    if (type == 'Polygon') {
      _parsePolygon(coords, featureProjectedPolys, (_, __) {});
    } else if (type == 'MultiPolygon') {
      for (final poly in coords) {
        _parsePolygon(poly, featureProjectedPolys, (_, __) {});
      }
    }

    for (final poly in featureProjectedPolys) {
      final points = poly.map((p) {
        final nx = ((p.x - minX) / width) * 2 - 1;
        final ny = -(((p.y - minY) / height) * 2 - 1);
        return LatLng(latitude: ny, longitude: nx);
      }).toList();
      normalizedPolygons.add(
        MapPolygon(points: points, properties: properties),
      );
    }
  }

  return NormalizedMapData(
    polygons: normalizedPolygons,
    bounds: MapBounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY),
  );
}

void _scanBounds(
  List polygonCoords,
  void Function(double x, double y) onPoint,
) {
  for (final ring in polygonCoords) {
    for (final coord in ring) {
      final lon = coord[0].toDouble();
      final lat = coord[1].toDouble();
      final x = MercatorProjection.projectX(lon);
      final y = MercatorProjection.projectY(lat);
      onPoint(x, y);
    }
  }
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
