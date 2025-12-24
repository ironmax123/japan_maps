import 'package:flutter/widgets.dart';
import 'package:japan_maps/src/format/geo_map.dart';
import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:flutter/services.dart';

class GeoMapWidget extends StatefulWidget {
  final String geoJsonPath;
  final LatLng center;
  const GeoMapWidget({
    super.key,
    required this.geoJsonPath,
    required this.center,
  });

  @override
  State<GeoMapWidget> createState() => _GeoMapWidgetState();
}

class _GeoMapWidgetState extends State<GeoMapWidget> {
  List<List<LatLng>> _polygons = [];

  double _scale = 1.5;
  Offset _offset = Offset.zero;

  double _startScale = 1.0;
  Offset _startOffset = Offset.zero;
  Offset _lastFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    final jsonString = await rootBundle.loadString('assets/map.geojson');
    final polygons = geoJsonToMap(jsonString);

    setState(() {
      _polygons = polygons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onScaleStart: (d) {
            _startScale = _scale;
            _startOffset = _offset;
            _lastFocal = d.focalPoint;
          },
          onScaleUpdate: (d) {
            setState(() {
              _scale = (_startScale * d.scale).clamp(0.5, 8.0);
              _offset = _startOffset + (d.focalPoint - _lastFocal);
            });
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: _GeoMapPainter(
              polygons: _polygons,
              center: widget.center,
              scale: _scale,
              offset: _offset,
              canvasSize: size,
            ),
          ),
        );
      },
    );
  }
}

class _GeoMapPainter extends CustomPainter {
  final List<List<LatLng>> polygons;
  final LatLng center;
  final double scale;
  final Offset offset;
  final Size canvasSize;

  _GeoMapPainter({
    required this.polygons,
    required this.center,
    required this.scale,
    required this.offset,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final baseScale = size.shortestSide / 2;
    final totalScale = baseScale * scale;

    final centerX = size.width / 2 + offset.dx;
    final centerY = size.height / 2 + offset.dy;

    for (final polygon in polygons) {
      final path = Path();

      for (int i = 0; i < polygon.length; i++) {
        final p = polygon[i];

        final dx = centerX + (p.longitude - center.longitude) * totalScale;
        final dy = centerY + (p.latitude - center.latitude) * totalScale;

        if (i == 0) {
          path.moveTo(dx, dy);
        } else {
          path.lineTo(dx, dy);
        }
      }

      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeoMapPainter old) {
    return old.scale != scale ||
        old.offset != offset ||
        old.polygons != polygons ||
        old.center != center;
  }
}
