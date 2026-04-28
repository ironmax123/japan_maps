# japan_maps_example

このディレクトリには、`japan_maps` パッケージの使用方法を示すサンプルアプリが含まれています。

*English documentation is available in [README.md](./README.md).*

## 紹介している機能

本アプリでは、以下の3つのマップ描画パターンを確認できます：

1. **Normal Map (通常の地図)** (`_MapWidget`)
   `JapanMapsWidget` を使用して、標準的な日本地図とその他の国を描画します。都道府県がタップされたときのコールバック処理などを確認できます。

2. **Color Map (単色の地図)** (`_MapColorWidget`)
   `JapanColorMapsWidget` を使用し、日本の都道府県すべてに同じ色を指定してオーバーレイ描画します。

3. **Color Map Prefecture (都道府県ごとの色分け)** (`_MapColorPrefectureWidget`)
   `JapanColorMapsWidget` に `Prefecture` オブジェクトを渡し、各都道府県に個別の色を指定してカラフルな日本地図を描画する例です。

## 実行方法

1. Flutter環境が構築されていることを確認してください。
2. `example` ディレクトリに移動し、アプリを実行します。
   ```bash
   cd example
   flutter pub get
   flutter run
   ```

## コード例

```dart
JapanColorMapsWidget(
  center: LatLng(latitude: 35.6895, longitude: 139.6917),
  mapColor: Colors.blueAccent.withAlpha(128),
  backgroundColor: Colors.black,
  otherCountryColor: Colors.grey,
  prefecture: Prefecture(
    hokkaido: Colors.red,
    tokyo: Colors.amber,
    // ... その他の都道府県の色を設定
  ),
  onPrefectureTap: (pref) {
    print('タップされた都道府県: ${pref.key}');
  },
)
```
