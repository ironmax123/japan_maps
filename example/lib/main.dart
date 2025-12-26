import 'package:flutter/material.dart';
import 'package:japan_maps/japan_maps.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japan MapsDemo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Japan MapsDemo'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const _MapWidget()),
            ),
            child: const Text('Normal Map'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const _MapColorWidget()),
            ),
            child: const Text('Color Map'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const _MapColorPrefectureWidget(),
              ),
            ),
            child: const Text('Color Map Prefecture'),
          ),
        ],
      ),
    );
  }
}

class _MapColorWidget extends StatelessWidget {
  const _MapColorWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Map')),
      body: JapanColorMapsWidget(
        center: LatLng(latitude: 35.6895, longitude: 139.6917),
        backgroundColor: Colors.indigo,
        otherCountryColor: Colors.grey,
        mapColor: Colors.greenAccent,

        /// optional
        // initialZoomLevel: 500.0,
        /// default is 50.0

        /// ontap prefecture
        /// default is null
        onPrefectureTap: (pref) {
          print('Tapped: ${pref.key}');
        },
      ),
    );
  }
}

class _MapColorPrefectureWidget extends StatelessWidget {
  const _MapColorPrefectureWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Map')),
      body: JapanColorMapsWidget(
        center: LatLng(latitude: 35.6895, longitude: 139.6917),
        mapColor: Colors.blueAccent.withAlpha(128),
        backgroundColor: Colors.black,
        otherCountryColor: Colors.grey,

        /// optional
        /// prefecture color
        prefecture: Prefecture(
          hokkaido: Colors.red,
          aomori: Colors.green,
          iwate: Colors.blue,
          miyagi: Colors.yellow,
          akita: Colors.orange,
          yamagata: Colors.purple,
          fukushima: Colors.brown,
          ibaraki: Colors.pink,
          tochigi: Colors.cyan,
          gunma: Colors.teal,
          saitama: Colors.lime,
          chiba: Colors.indigo,
          tokyo: Colors.amber,
          kanagawa: Colors.deepPurple,
          niigata: Colors.deepOrange,
          toyama: Colors.lightBlue,
          ishikawa: Colors.lightGreen,
          fukui: Colors.redAccent,
          yamanashi: Colors.blueAccent,
          nagano: Colors.greenAccent,
          gifu: Colors.yellowAccent,
          shizuoka: Colors.orangeAccent,
          aichi: Colors.purpleAccent,
          mie: Colors.pinkAccent,
          shiga: Colors.cyanAccent,
          kyoto: Colors.tealAccent,
          osaka: Colors.limeAccent,
          hyogo: Colors.indigoAccent,
          nara: Colors.amberAccent,
          wakayama: Colors.deepPurpleAccent,
          tottori: Colors.lightBlueAccent,
          shimane: Colors.lightGreenAccent,
          okayama: Colors.red.withAlpha(128),
          hiroshima: Colors.green.withAlpha(128),
          yamaguchi: Colors.blue.withAlpha(128),
          tokushima: Colors.yellow.withAlpha(128),
          kagawa: Colors.orange.withAlpha(128),
          ehime: Colors.purple.withAlpha(128),
          kochi: Colors.brown.withAlpha(128),
          fukuoka: Colors.pink.withAlpha(128),
          saga: Colors.cyan.withAlpha(128),
          nagasaki: Colors.teal.withAlpha(128),
          kumamoto: Colors.lime.withAlpha(128),
          oita: Colors.indigo.withAlpha(128),
          miyazaki: Colors.amber.withAlpha(128),
          kagoshima: Colors.deepPurple.withAlpha(128),
          okinawa: Colors.deepOrange.withAlpha(128),
        ),
        onPrefectureTap: (pref) {
          print('Tapped: ${pref.key}');
        },

        /// optional
        // initialZoomLevel: 500.0,
        /// default is 50.0
      ),
    );
  }
}

class _MapWidget extends StatelessWidget {
  const _MapWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('normal map')),
      body: JapanMapsWidget(
        center: LatLng(latitude: 35.6895, longitude: 139.6917),
        backgroundColor: Color(0xff2f4f4f),
        otherCountryColor: Color(0xff4b0082),
        onPrefectureTap: (pref) {
          print('Tapped: ${pref.key}');
        },

        /// optional
        /// default is 50.0
        initialZoomLevel: 500.0,
      ),
    );
  }
}
