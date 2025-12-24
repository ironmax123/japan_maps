import 'package:flutter/widgets.dart';
import 'package:japan_maps/src/format/geo_map.dart';
import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:flutter/services.dart';
import 'package:japan_maps/src/model/normalized_map.dart';

class GeoMapWidget extends StatefulWidget {
  final LatLng center; // raw lat/lon
  final String geoJsonPath;
  const GeoMapWidget({
    super.key,
    required this.center,
    required this.geoJsonPath,
  });

  @override
  State<GeoMapWidget> createState() => _GeoMapWidgetState();
}

class _GeoMapWidgetState extends State<GeoMapWidget> {
  NormalizedMapData? _mapData;
  LatLng? _centerN;

  double _scale = 3.0;
  Offset _offset = Offset.zero;

  double _startScale = 1.0;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    final json = await rootBundle.loadString('assets/map.geojson');
    final mapData = geoJsonToMercatorMap(json);
    final centerN = normalizeCenter(widget.center, mapData);

    if (!mounted) return;

    setState(() {
      _mapData = mapData;
      _centerN = centerN;
      _offset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapData = _mapData;
    final centerN = _centerN;

    if (mapData == null || centerN == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return GestureDetector(
          onScaleStart: (d) {
            _startScale = _scale;
            _startOffset = _offset;
            _startFocal = d.focalPoint;
          },
          onScaleUpdate: (d) {
            setState(() {
              _scale = (_startScale * d.scale).clamp(0.5, 20.0);
              _offset = _startOffset + (d.focalPoint - _startFocal);
            });
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: _GeoMapPainter(
              polygons: mapData.polygons,
              centerN: centerN,
              scale: _scale,
              offset: _offset,
              canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }
}

class _GeoMapPainter extends CustomPainter {
  final List<List<LatLng>> polygons; // normalized (-1..1)
  final LatLng centerN; // normalized (-1..1)
  final double scale;
  final Offset offset;
  final Size canvasSize;

  _GeoMapPainter({
    required this.polygons,
    required this.centerN,
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

    final cx = size.width / 2 + offset.dx;
    final cy = size.height / 2 + offset.dy;

    for (final poly in polygons) {
      if (poly.isEmpty) continue;

      final path = Path();
      for (int i = 0; i < poly.length; i++) {
        final p = poly[i];

        final dx = cx + (p.longitude - centerN.longitude) * totalScale;
        final dy = cy + (p.latitude - centerN.latitude) * totalScale;

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
        old.centerN != centerN ||
        old.polygons != polygons;
  }
}
