import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('assets/map.geojson');
  final content = await file.readAsString();
  final json = jsonDecode(content);
  final features = json['features'] as List;
  for (final feature in features) {
    var name = feature['properties'] != null
        ? feature['properties']['name']
        : null;
    if (name == null) {
      // Check if coordinates match Japan (approx 130-145 E, 30-45 N)
      var geometry = feature['geometry'];
      if (geometry != null) {
        var type = geometry['type'];
        var coords = geometry['coordinates'];
        // Simplified check: just grab a point and see if it's in range
        double lon = 0;
        double lat = 0;
        if (type == 'Polygon') {
          lon = coords[0][0][0].toDouble();
          lat = coords[0][0][1].toDouble();
        } else if (type == 'MultiPolygon') {
          lon = coords[0][0][0][0].toDouble();
          lat = coords[0][0][0][1].toDouble();
        }
        if (lon > 120 && lon < 150 && lat > 20 && lat < 50) {
          print('Found candidate for Japan: $lon, $lat');
          print('Properties: ${feature['properties']}');
        }
      }
    }
  }
}
