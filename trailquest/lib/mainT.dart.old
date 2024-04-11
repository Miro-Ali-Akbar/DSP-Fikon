import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'dart:collection';
import 'api_key.dart'; 

void main() {
  runApp(const MyApp());
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

//fetches elevation of a coordinate
Future<double> _getElevation(LatLng coordinates) async {
    final apiKey = YOUR_API_KEY;
    final url = 'https://maps.googleapis.com/maps/api/elevation/json?locations=${coordinates.latitude},${coordinates.longitude}&key=$apiKey';
    final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['elevation'];
        } else {
          return Future.error('Error retrieving elevation data'); 
        }
      } else {
        return Future.error('Failed to load elevation data'); 
      }
  }

//checks is elevation difference is greater than 20
Future<bool> _elevationOK(List<LatLng> points) async {

  double currentElevation; 
  double nextElevation; 

  for (int i = 0; i < points.length - 1; i++) {
    currentElevation = await _getElevation(points[i]); 
    nextElevation = await _getElevation(points[i+1]); 
    
    double difference = nextElevation - currentElevation; 

    if (difference < -20 || difference > 20) {
      return false; 
    }
    
  }
  return true; 
}

//fetches the stairs of Uppsala
Future<List<Marker>> fetchStairsData(List<Marker> markers) async {
  //TODO: hard coded to Uppsala, might need to be different if continious loading is neccessary (e.g need to follow camera, toilet.dart = ex.)
  final url = 'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];area(id:3600305455)->.searchArea;(way["highway"="steps"](area.searchArea););(._;>;);out;';  
  final response = await http.get(Uri.parse(url));
  print("Fetching stairs from: $url");
  
  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
      List<dynamic> elements = decoded['elements'];
        return markers = _parseStairsData(elements);
  } else {
    print('Failed to load stairs data: ${response.body}');
    throw Exception('Failed to load stairs data');
  }
}

//parses stair data
List<Marker> _parseStairsData(List<dynamic> data) {
  List<Marker> parsedMarkers = [];
  HashMap<int, Map<String, dynamic>> nodes = HashMap();
  
  // Parse nodes
  for (var item in data) {
    if (item['type'] == 'node') {
      nodes[item['id']] = {'lat': item['lat'], 'lon': item['lon']};
    }
  }

  // Parse ways
  for (var item in data) {
    if (item['type'] == 'way' && item['tags'] != null && item['tags']['highway'] == 'steps') {
      List<LatLng> coordinates = [];
      if (item['nodes'] != null) {
        for (var nodeId in item['nodes']) {
          var node = nodes[nodeId];
          if (node != null) {
            coordinates.add(LatLng(node['lat'], node['lon']));
          }
        }
        if (coordinates.isNotEmpty) {
          // Assuming first node is the starting point of the stairs
          LatLng firstNode = coordinates.first;
          String snippet = '';
          if (item['tags'].containsKey('surface')) {
            snippet = item['tags']['surface']; 
          } else {
            snippet = 'No data of stair type';
          }
          parsedMarkers.add(
            Marker(
              markerId: MarkerId(item['id'].toString()),
              position: firstNode,
              infoWindow: InfoWindow(
                title: 'Stairs',
                snippet: snippet,
              ),
            ),
          );
        }
      }
    }
  }

  return parsedMarkers;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Routes Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapsRoutesExample(title: 'GMR Demo Home'),
    );
  }
}

class MapsRoutesExample extends StatefulWidget {
  const MapsRoutesExample({super.key, required this.title});
  final String title;

  @override
  _MapsRoutesExampleState createState() => _MapsRoutesExampleState();
}

class _MapsRoutesExampleState extends State<MapsRoutesExample> {
  late GoogleMapController mapController;

  Position? pos;

  List<LatLng> points = [
    const LatLng(59.84429621673012, 17.638228177426775),
    const LatLng(59.84643220507929, 17.63963225848925),
    const LatLng(59.85009456157953, 17.643307828593034),
    const LatLng(59.85444306179348, 17.63943133739685),
  ];

  MapsRoutes route = MapsRoutes();
  DistanceCalculator distanceCalculator = DistanceCalculator();
  String googleApiKey = YOUR_API_KEY;
  String totalDistance = 'No route';

  static const start = LatLng(59.85444306179348, 17.63943133739685);

  late Future<double>? startElevation = null;
  late Future<bool>? elevationOK = null;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TrailQuest'),
          elevation: 2,
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: GoogleMap(
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                polylines: route.routes,
                initialCameraPosition: const CameraPosition(
                  zoom: 15.0,
                  target: start,
                ),                
                markers: Set<Marker>.of(markers),
                onMapCreated: _onMapCreated, 
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(totalDistance, style: const TextStyle(fontSize: 25.0)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16.0, 
              left: 16.0, 
              child: Container(
                width: 200,
                height: 80,
                color: Colors.blue, 
                child: Column(
                  children: [
                       FutureBuilder<double>(
                        future: startElevation,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              'Elevation: ${snapshot.data}',
                              style: TextStyle(color: Colors.white),
                            );
                          } else {
                            return const Text(
                              'Elevation: N/A', 
                              style: TextStyle(color: Colors.white), 
                            );
                          }
                        },
                    ),
                    FutureBuilder<bool>(
                        future: elevationOK,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              'Elevation ok: ${snapshot.data}',
                              style: TextStyle(color: Colors.white),
                            );
                          } else {
                            return const Text(
                              'Elevation ok: N/A', 
                              style: TextStyle(color: Colors.white), 
                            );
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await route.drawRoute(points, 'Test routes',
                const Color.fromRGBO(130, 78, 210, 1.0), googleApiKey,
                travelMode: TravelModes.walking);
            setState(() {
              totalDistance = distanceCalculator.calculateRouteDistance(points,
                  decimals: 1);
            });
            _determinePosition().then((value) async {
              mapController.animateCamera(CameraUpdate.newLatLngZoom(
                  LatLng(start.latitude, start.longitude), 14));
              setState(() {
                startElevation = _getElevation(start);
                elevationOK = _elevationOK(points); 
              });
              try {
                List<Marker> fetchedMarkers = await fetchStairsData(markers);
                setState(() {
                  markers = fetchedMarkers;
                });
              } catch (error) {
                print('Error fetching stairs data: $error');
              }
            });
          },
        ),
      ),
    );
  }
}
