import 'package:flutter/widgets.dart';

class JapanMapsController extends ChangeNotifier {
  double _scale;
  Offset _offset = Offset.zero;

  JapanMapsController({required double zoomLevel}) : _scale = zoomLevel;

  double get scale => _scale;
  Offset get offset => _offset;

  void updateTransform(double scale, Offset offset) {
    if (_scale != scale || _offset != offset) {
      _scale = scale;
      _offset = offset;
      notifyListeners();
    }
  }
}
