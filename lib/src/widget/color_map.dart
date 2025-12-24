import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:japan_maps/japan_maps.dart';
import 'package:japan_maps/src/format/geo_map.dart';
import 'package:japan_maps/src/model/normalized_map.dart';

class JapanColorMapsWidget extends StatefulWidget {
  final LatLng center; // raw lat/lon
  final double initialZoomLevel;
  final Prefecture? prefecture;
  final Color mapColor;

  const JapanColorMapsWidget({
    super.key,
    required this.center,
    required this.mapColor,
    this.initialZoomLevel = 50.0,
    this.prefecture,
  });

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
    _controller = JapanMapsController(zoomLevel: widget.initialZoomLevel);
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
              mapColor: widget.mapColor,
              polygons: _mapData!.polygons,
              centerN: _centerN!,
              scale: _controller.scale,
              offset: _controller.offset,
              prefecture: widget.prefecture,
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
  final Color mapColor;

  final Prefecture? prefecture;

  _JapanColorPainter({
    required this.polygons,
    required this.centerN,
    required this.scale,
    required this.offset,
    required this.mapColor,
    this.prefecture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()..style = PaintingStyle.fill;

    final baseScale = size.shortestSide / 2;
    final totalScale = baseScale * scale;

    final cx = size.width / 2 + offset.dx;
    final cy = size.height / 2 + offset.dy;

    for (final poly in polygons) {
      // Check if it's Japan based on the existence of 'nam_ja' property
      if (poly.properties['nam_ja'] == null) continue;

      if (poly.points.isEmpty) continue;

      final id = poly.properties['id'];
      Color color = mapColor;

      if (prefecture != null && id is int) {
        color = _getColor(prefecture!, id) ?? mapColor;
      }

      basePaint.color = color;

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
      canvas.drawPath(path, basePaint);
    }
  }

  Color? _getColor(Prefecture p, int id) {
    switch (id) {
      case 1:
        return p.hokkaido;
      case 2:
        return p.aomori;
      case 3:
        return p.iwate;
      case 4:
        return p.miyagi;
      case 5:
        return p.akita;
      case 6:
        return p.yamagata;
      case 7:
        return p.fukushima;
      case 8:
        return p.ibaraki;
      case 9:
        return p.tochigi;
      case 10:
        return p.gunma;
      case 11:
        return p.saitama;
      case 12:
        return p.chiba;
      case 13:
        return p.tokyo;
      case 14:
        return p.kanagawa;
      case 15:
        return p.niigata;
      case 16:
        return p.toyama;
      case 17:
        return p.ishikawa;
      case 18:
        return p.fukui;
      case 19:
        return p.yamanashi;
      case 20:
        return p.nagano;
      case 21:
        return p.gifu;
      case 22:
        return p.shizuoka;
      case 23:
        return p.aichi;
      case 24:
        return p.mie;
      case 25:
        return p.shiga;
      case 26:
        return p.kyoto;
      case 27:
        return p.osaka;
      case 28:
        return p.hyogo;
      case 29:
        return p.nara;
      case 30:
        return p.wakayama;
      case 31:
        return p.tottori;
      case 32:
        return p.shimane;
      case 33:
        return p.okayama;
      case 34:
        return p.hiroshima;
      case 35:
        return p.yamaguchi;
      case 36:
        return p.tokushima;
      case 37:
        return p.kagawa;
      case 38:
        return p.ehime;
      case 39:
        return p.kochi;
      case 40:
        return p.fukuoka;
      case 41:
        return p.saga;
      case 42:
        return p.nagasaki;
      case 43:
        return p.kumamoto;
      case 44:
        return p.oita;
      case 45:
        return p.miyazaki;
      case 46:
        return p.kagoshima;
      case 47:
        return p.okinawa;
      default:
        return null;
    }
  }

  @override
  bool shouldRepaint(covariant _JapanColorPainter old) {
    return old.scale != scale ||
        old.offset != offset ||
        old.centerN != centerN ||
        old.polygons != polygons ||
        old.mapColor != mapColor ||
        old.prefecture !=
            prefecture; // Assuming Prefecture checks equality correctly or re-creates
  }
}
