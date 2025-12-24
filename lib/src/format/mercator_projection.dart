import 'dart:math';

class MercatorProjection {
  static const double _radian = pi / 180.0;

  static double projectX(double lon) {
    return lon * _radian;
  }

  static double projectY(double lat) {
    final clampedLat = lat.clamp(-85.05112878, 85.05112878);
    final rad = clampedLat * _radian;
    return log(tan(pi / 4 + rad / 2));
  }
}
