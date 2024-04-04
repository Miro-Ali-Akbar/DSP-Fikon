import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSM Data on GMaps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapsScreen(),
    );
  }
}

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  MapsScreenState createState() => MapsScreenState();
}

class MapsScreenState extends State<MapsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Toilet> toilets = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        myLocationEnabled: true,
        minMaxZoomPreference: const MinMaxZoomPreference(10, 22),
        markers: _toiletsToMarkerList(toilets),
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 13.0,
        ),
        onCameraIdle: () async {
          final controller = await _controller.future;
          final area = await controller.getVisibleRegion();
          final bounds = _getAreaString(area);
          final toiletsRes = await _fetchToilets(bounds);
          setState(() {
            toilets = toiletsRes;
          });
        });
  }
}

_getAreaString(LatLngBounds area) {
  String north = area.northeast.latitude.toStringAsFixed(10);
  String east = area.northeast.longitude.toStringAsFixed(10);
  String south = area.southwest.latitude.toStringAsFixed(10);
  String west = area.southwest.longitude.toStringAsFixed(10);
  return '$west,$south,$east,$north';
}

class Toilet {
  final String id;
  final LatLng position;

  Toilet(this.id, this.position);

  Toilet.fromJson(Map<String, dynamic> json)
      : id = json['id'].toString(),
        position = LatLng(json['lat'], json['lon']);
}

Future<List<Toilet>> _fetchToilets(String bbox) async {
  try {
    const endpoint = 'https://overpass-api.de/api/interpreter';
    final queryParam =
        '?data=[bbox][out:json][timeout:25];(node[amenity=toilets];);out;&bbox=$bbox';

    var response = await http.get(Uri.parse(endpoint + queryParam));
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var osmToilets = decodedResponse['elements'] as Iterable<dynamic>? ?? [];
    List<Toilet> toilets = [];
    for (var element in osmToilets) {
      try {
        toilets.add(Toilet.fromJson(element));
      } catch (error) {
        return [];
      }
    }
    return toilets;
  } catch (error) {
    return [];
  }
}

_toiletsToMarkerList(List<Toilet> toilets) {
  var markerList = toilets
      .map((e) => Marker(markerId: MarkerId(e.id), position: e.position));
  return Set<Marker>.from(markerList);
}