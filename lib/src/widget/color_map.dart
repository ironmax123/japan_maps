import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:japan_maps/src/format/geo_map.dart';
import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:japan_maps/src/model/normalized_map.dart';
import 'package:japan_maps/src/map/map_controller.dart';
import 'package:japan_maps/src/widget/map.dart';

class JapanColorMapsWidget extends StatefulWidget {
  final LatLng center; // raw lat/lon

  const JapanColorMapsWidget({super.key, required this.center});

  @override
  State<JapanColorMapsWidget> createState() => _JapanColorMapsWidgetState();
}

class _JapanColorMapsWidgetState extends State<JapanColorMapsWidget> {
  late JapanMapsController _controller;
  NormalizedMapData? _mapData;
  LatLng? _centerN;

  @override
  void initState() {
    super.initState();
    _controller = JapanMapsController();
    _controller.addListener(_onControllerChange);
    _loadGeoJson();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    setState(() {});
  }

  Future<void> _loadGeoJson() async {
    final json = await rootBundle.loadString(
      'packages/japan_maps/assets/map.geojson',
    );
    final mapData = geoJsonToMercatorMap(json);
    final centerN = normalizeCenter(widget.center, mapData);

    if (!mounted) return;

    setState(() {
      _mapData = mapData;
      _centerN = centerN;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_mapData == null || _centerN == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        JapanMapsWidget(center: widget.center, controller: _controller),
        IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: _JapanColorPainter(
              polygons: _mapData!.polygons,
              centerN: _centerN!,
              scale: _controller.scale,
              offset: _controller.offset,
            ),
          ),
        ),
      ],
    );
  }
}

class _JapanColorPainter extends CustomPainter {
  final List<MapPolygon> polygons;
  final LatLng centerN;
  final double scale;
  final Offset offset;

  _JapanColorPainter({
    required this.polygons,
    required this.centerN,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colorPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(
        0xFFFF0000,
      ).withOpacity(0.5); // Example color for Japan

    final baseScale = size.shortestSide / 2;
    final totalScale = baseScale * scale;

    final cx = size.width / 2 + offset.dx;
    final cy = size.height / 2 + offset.dy;

    for (final poly in polygons) {
      // Check if it's Japan based on the existence of 'nam_ja' property
      if (poly.properties['nam_ja'] == null) continue;

      if (poly.points.isEmpty) continue;

      final path = Path();
      for (int i = 0; i < poly.points.length; i++) {
        final p = poly.points[i];

        final dx = cx + (p.longitude - centerN.longitude) * totalScale;
        final dy = cy + (p.latitude - centerN.latitude) * totalScale;

        if (i == 0) {
          path.moveTo(dx, dy);
        } else {
          path.lineTo(dx, dy);
        }
      }
      path.close();
      canvas.drawPath(path, colorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JapanColorPainter old) {
    return old.scale != scale ||
        old.offset != offset ||
        old.centerN != centerN ||
        old.polygons != polygons;
  }
}
