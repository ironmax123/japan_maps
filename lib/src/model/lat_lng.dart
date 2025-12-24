import 'dart:math';

class LatLng extends Point<double> {
  final double latitude;
  final double longitude;

  LatLng({required this.latitude, required this.longitude})
    : super(latitude, longitude);
}
