# japan_maps_example

This directory contains a sample application demonstrating how to use the `japan_maps` package.

## Features Demonstrated

The application provides three examples for rendering Japan maps:

1. **Normal Map** (`_MapWidget`)
   Uses `JapanMapsWidget` to render a standard adjustable map of Japan alongside other countries.
   Provides callbacks for tapping on individual prefectures.

2. **Color Map** (`_MapColorWidget`)
   Uses `JapanColorMapsWidget` to apply a uniform color overlay across all mapped Japanese prefectures.

3. **Color Map (Prefecture Colors)** (`_MapColorPrefectureWidget`)
   Uses `JapanColorMapsWidget` configured with a `Prefecture` object to apply distinct colors to each individual prefecture.

## How to Run

1. Make sure you have Flutter installed.
2. Navigate into the `example` directory:
   ```bash
   cd example
   flutter pub get
   flutter run
   ```

## Usage Example

```dart
JapanColorMapsWidget(
  center: LatLng(latitude: 35.6895, longitude: 139.6917),
  mapColor: Colors.blueAccent.withAlpha(128),
  backgroundColor: Colors.black,
  otherCountryColor: Colors.grey,
  prefecture: Prefecture(
    hokkaido: Colors.red,
    tokyo: Colors.amber,
    // ... configure other prefectures
  ),
  onPrefectureTap: (pref) {
    print('Tapped: ${pref.key}');
  },
)
```
