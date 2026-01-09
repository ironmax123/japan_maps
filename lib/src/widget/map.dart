import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:japan_maps/src/format/geo_map.dart';
import 'package:japan_maps/src/map/map_controller.dart';
import 'package:japan_maps/src/map/prefecture_polygon.dart';
import 'package:japan_maps/src/model/lat_lng.dart';
import 'package:japan_maps/src/model/normalized_map.dart';

class JapanMapsWidget extends StatefulWidget {
  final LatLng center; // raw lat/lon
  final JapanMapsController? controller;
  final double initialZoomLevel;
  final Color backgroundColor;
  final Color otherCountryColor;
  final ValueChanged<PrefecturePolygon>? onPrefectureTap;
  final Color? onTapedColor;

  const JapanMapsWidget({
    super.key,
    required this.center,
    required this.backgroundColor,
    required this.otherCountryColor,
    this.controller,
    this.initialZoomLevel = 50.0,
    this.onPrefectureTap,
    this.onTapedColor,
  });

  @override
  State<JapanMapsWidget> createState() => _JapanMapsWidgetState();
}

class _JapanMapsWidgetState extends State<JapanMapsWidget> {
  // ... (previous state variables)
  NormalizedMapData? _mapData;
  LatLng? _centerN;

  late JapanMapsController _controller;
  bool _isInternalController = false;

  double _startScale = 1.0;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;

  String? _tappedPrefectureName;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = JapanMapsController(zoomLevel: widget.initialZoomLevel);
      _isInternalController = true;
    }
    _controller.updateTransform(widget.initialZoomLevel, _controller.offset);
    _controller.addListener(_onControllerChange);
    _loadGeoJson();
  }

  // ... (dispose and other methods same as before)
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
        return Container(
          color: widget.backgroundColor,
          child: GestureDetector(
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
            onTapUp: (d) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final cx = size.width / 2 + _controller.offset.dx;
              final cy = size.height / 2 + _controller.offset.dy;
              final baseScale = size.shortestSide / 2;
              final totalScale = baseScale * _controller.scale;

              final dx = d.localPosition.dx;
              final dy = d.localPosition.dy;

              // Convert screen point to normalized point
              // dx = cx + (lon - centerN.lon) * totalScale
              // => lon = (dx - cx) / totalScale + centerN.lon
              final lon = (dx - cx) / totalScale + centerN.longitude;
              final lat = (dy - cy) / totalScale + centerN.latitude;

              final tapPoint = LatLng(latitude: lat, longitude: lon);

              for (final poly in mapData.polygons) {
                if (poly.properties['nam_ja'] == null) continue;

                // Using isPointInPolygon from prefecture_polygon.dart
                if (isPointInPolygon(tapPoint, poly.points)) {
                  setState(() {
                    _tappedPrefectureName = poly.properties['nam_ja'];
                  });
                  widget.onPrefectureTap?.call(
                    PrefecturePolygon(
                      key: poly.properties['nam_ja'],
                      polygon: poly.points,
                    ),
                  );
                  break;
                }
              }
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: _GeoMapPainter(
                polygons: mapData.polygons,
                centerN: centerN,
                scale: _controller.scale,
                offset: _controller.offset,
                canvasSize: Size(constraints.maxWidth, constraints.maxHeight),
                color: widget.otherCountryColor,
                tappedPrefectureName: _tappedPrefectureName,
                onTapedColor: widget.onTapedColor,
              ),
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
  final Color color;
  final String? tappedPrefectureName;
  final Color? onTapedColor;

  _GeoMapPainter({
    required this.polygons,
    required this.centerN,
    required this.scale,
    required this.offset,
    required this.canvasSize,
    required this.color,
    this.tappedPrefectureName,
    this.onTapedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withAlpha(64);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color;

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

      if (onTapedColor != null &&
          tappedPrefectureName != null &&
          poly.properties['nam_ja'] == tappedPrefectureName) {
        final tappedPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = onTapedColor!;
        canvas.drawPath(path, tappedPaint);
      } else {
        canvas.drawPath(path, fillPaint);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GeoMapPainter old) {
    return old.scale != scale ||
        old.offset != offset ||
        old.centerN != centerN ||
        old.polygons != polygons ||
        old.tappedPrefectureName != tappedPrefectureName ||
        old.onTapedColor != onTapedColor;
  }
}
