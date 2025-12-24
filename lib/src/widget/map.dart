import 'package:flutter/widgets.dart';
import 'package:japan_maps/src/format/geo_map.dart';
import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:flutter/services.dart';
import 'package:japan_maps/src/model/normalized_map.dart';
import 'package:japan_maps/src/map/map_controller.dart';

class JapanMapsWidget extends StatefulWidget {
  final LatLng center; // raw lat/lon
  final JapanMapsController? controller;
  final double initialZoomLevel;

  const JapanMapsWidget({
    super.key,
    required this.center,
    this.controller,
    this.initialZoomLevel = 50.0,
  });

  @override
  State<JapanMapsWidget> createState() => _JapanMapsWidgetState();
}

class _JapanMapsWidgetState extends State<JapanMapsWidget> {
  NormalizedMapData? _mapData;
  LatLng? _centerN;

  late JapanMapsController _controller;
  bool _isInternalController = false;

  double _startScale = 1.0;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = JapanMapsController(zoomLevel: widget.initialZoomLevel);
      _isInternalController = true;
    }
    _controller.addListener(_onControllerChange);
    _loadGeoJson();
  }

  @override
  void didUpdateWidget(covariant JapanMapsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onControllerChange);
      if (_isInternalController) {
        // We don't dispose internal controller here because we might want to keep state?
        // Usually if switching to external, we just drop internal.
      }

      if (widget.controller != null) {
        _controller = widget.controller!;
        _isInternalController = false;
      } else {
        _controller = JapanMapsController(zoomLevel: widget.initialZoomLevel);
        _isInternalController = true;
      }
      _controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    if (_isInternalController) {
      _controller.dispose();
    }
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
      // Reset offset when map loads, but only if controller is fresh or we want to force it?
      // For now, let's just let controller keep its state or init state.
      // _controller.updateTransform(_controller.scale, Offset.zero);
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
            _startScale = _controller.scale;
            _startOffset = _controller.offset;
            _startFocal = d.focalPoint;
          },
          onScaleUpdate: (d) {
            final newScale = (_startScale * d.scale).clamp(0.5, 10000.0);
            final newOffset = _startOffset + (d.focalPoint - _startFocal);
            _controller.updateTransform(newScale, newOffset);
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: _GeoMapPainter(
              polygons: mapData.polygons,
              centerN: centerN,
              scale: _controller.scale,
              offset: _controller.offset,
              canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        );
      },
    );
  }
}

class _GeoMapPainter extends CustomPainter {
  final List<MapPolygon> polygons; // normalized (-1..1)
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
