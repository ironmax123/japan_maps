# japan_maps

A Flutter package for displaying and interacting with customizable maps of Japan.

## Features

- 🗺️ **Display Japan Map**: Easily render a full map of Japan.
- 🎨 **Customizable Colors**: Customize colors for the background, the map itself, other countries, and individual prefectures.
- 👆 **Interactive**: Handle tap events on specific prefectures.
- 🔍 **Zoom & Pan**: Supports smooth zooming and panning functionality.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  japan_maps: ^0.0.1
```

Or run this command in your terminal:

```bash
flutter pub add japan_maps
```

## Usage

### Basic Map

Use `JapanMapsWidget` to display a standard map. You can customize the background and other country colors.

```dart
import 'package:flutter/material.dart';
import 'package:japan_maps/japan_maps.dart';

class MyMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JapanMapsWidget(
        center: LatLng(latitude: 35.6895, longitude: 139.6917), // Initial center (Tokyo)
        initialZoomLevel: 50.0, // Optional: Default is 50.0
        backgroundColor: Color(0xff2f4f4f),
        otherCountryColor: Color(0xff4b0082),
        onPrefectureTap: (pref) {
          print('Tapped: ${pref.key}');
        },
      ),
    );
  }
}
```

### Colored Map

Use `JapanColorMapsWidget` to customize the color of each prefecture individually.

```dart
import 'package:flutter/material.dart';
import 'package:japan_maps/japan_maps.dart';

class MyColorMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JapanColorMapsWidget(
        center: LatLng(latitude: 35.6895, longitude: 139.6917),
        mapColor: Colors.blueAccent.withAlpha(128), // Default color for prefectures
        backgroundColor: Colors.black,
        otherCountryColor: Colors.grey,
        
        // Define specific colors for prefectures
        prefecture: Prefecture(
          hokkaido: Colors.red,
          tokyo: Colors.amber,
          osaka: Colors.limeAccent,
          fukuoka: Colors.pink.withAlpha(128),
          // Add other prefectures as needed...
        ),
        
        onPrefectureTap: (pref) {
          print('Tapped: ${pref.key}');
        },
      ),
    );
  }
}
```

---

# japan_maps (日本語)

日本地図を表示し、カスタマイズやインタラクションを行うためのFlutterパッケージです。

## 特徴

- 🗺️ **日本地図の表示**: 日本全体の地図を簡単に描画できます。
- 🎨 **色のカスタマイズ**: 背景、地図全体、他国、そして各都道府県ごとの色を自由にカスタマイズ可能です。
- 👆 **インタラクティブ**: 都道府県ごとのタップイベントを取得できます。
- 🔍 **ズーム & パン**: スムーズなズームとパン操作をサポートしています。

## インストール

`pubspec.yaml` ファイルに以下を追加してください：

```yaml
dependencies:
  japan_maps: ^0.0.1
```

または、ターミナルで以下のコマンドを実行してください：

```bash
flutter pub add japan_maps
```

## 使い方

### 基本的な地図

`JapanMapsWidget` を使用して標準的な地図を表示します。背景色や他国の色を指定できます。

```dart
import 'package:flutter/material.dart';
import 'package:japan_maps/japan_maps.dart';

class MyMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JapanMapsWidget(
        center: LatLng(latitude: 35.6895, longitude: 139.6917), // 初期中心位置（東京）
        initialZoomLevel: 50.0, // オプション: デフォルトは 50.0
        backgroundColor: Color(0xff2f4f4f),
        otherCountryColor: Color(0xff4b0082),
        onPrefectureTap: (pref) {
          print('タップされた都道府県: ${pref.key}');
        },
      ),
    );
  }
}
```

### 色分け地図

`JapanColorMapsWidget` を使用すると、各都道府県の色を個別に指定でき、ヒートマップや地域別の色分け表現に最適です。

```dart
import 'package:flutter/material.dart';
import 'package:japan_maps/japan_maps.dart';

class MyColorMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: JapanColorMapsWidget(
        center: LatLng(latitude: 35.6895, longitude: 139.6917),
        mapColor: Colors.blueAccent.withAlpha(128), // 都道府県のデフォルト色
        backgroundColor: Colors.black,
        otherCountryColor: Colors.grey,
        
        // 特定の都道府県の色を指定
        prefecture: Prefecture(
          hokkaido: Colors.red,
          tokyo: Colors.amber,
          osaka: Colors.limeAccent,
          fukuoka: Colors.pink.withAlpha(128),
          // 必要に応じて他の都道府県も追加...
        ),
        
        onPrefectureTap: (pref) {
          print('タップされた都道府県: ${pref.key}');
        },
      ),
    );
  }
}
```
