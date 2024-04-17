import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'dart:collection';
import 'api_key.dart'; 
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math'; 
import 'package:flutter_map_math/flutter_geo_math.dart';

String totalDistance = 'No Route'; 
bool inIntervall = false; 
Map<MarkerId, Marker> markers = {};
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();

const start = LatLng(59.85444306179348, 17.63943133739685);


void main() {
  runApp(const MyApp());
}

void reset() {
  markers = {}; 
  polylines = {};
  polylineCoordinates = [];
  polylinePoints = PolylinePoints();
  
  /// origin marker
    _addMarker(LatLng(start.latitude, start.longitude), "origin",
        BitmapDescriptor.defaultMarker);
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



Future<List<PolylineWayPoint>> _getWayPoints(LatLng start) async {
    List<PolylineWayPoint> wayPoints = [];

    const routeLength = 4; 
    const radius = routeLength / (pi + 2); 

    wayPoints.add(PolylineWayPoint(location: "${start.latitude},${start.longitude}"));
    print(start); 
    //bool noStairs = await _checkStairs(start); 

    int pointsCount = 4; //TODO: increase!
    final random = Random();
    double startDirection = random.nextDouble() * (2*pi + 1.0);

    double routeDistance = 0; 

  // calculates each new waypoint
  for (int i = 1; i <= pointsCount; i++) {
    double angle = (pi * i) / (2 * pointsCount) + startDirection;
    double lat = start.latitude + radius * sin(angle) / 110.574;
    double lon = start.longitude + radius * cos(angle) / (111.320 * cos(lat * pi / 180));

    wayPoints.add(PolylineWayPoint(location: "$lat,$lon"));
  }

  // calculates distance between each waypoint
  for (int i = 0; i < wayPoints.length - 1; i++) {
    LatLng origin = _parseLatLng(wayPoints[i].location);
    LatLng destination = _parseLatLng(wayPoints[i + 1].location);

    bool noStairs = await _checkStairs(origin);
    print(noStairs); 
    //if (!noStairs) {
    //  _furtherCheckStairs(origin); 
    //}

    double distance = await _getWalkingDistance(origin, destination);

    print("Distance between waypoint $i and ${i + 1}: $distance meters");
    routeDistance += distance; 
  }

  print(routeDistance); 
 
  if (routeDistance > routeLength * 1000 - 2000 && routeDistance < routeLength * 1000 + 2000) { //+- 500m //TODO: edit!
    inIntervall = true; 
    totalDistance = routeDistance.toString(); 
  } 

  return wayPoints;
}

Future<bool> _checkStairs(LatLng waypoint) async {
  final url = 'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];way["highway"="steps"](around:150, ${waypoint.latitude}, ${waypoint.longitude});(._;>;);out;';  
  final response = await http.get(Uri.parse(url));
  print("Fetching stairs from: $url");

  if (response.statusCode == 200) {
    //Map<String, dynamic> jsonData = json.decode(response.body);
    final decoded = json.decode(response.body);
    List<dynamic> elements = decoded['elements'];

    print(elements); 

    HashMap<int, Map<String, dynamic>> nodes = HashMap();
    
    // Parse nodes
    for (var item in elements) {
    if (item['type'] == 'node') {
      nodes[item['id']] = {'lat': item['lat'], 'lon': item['lon']};
    }
  }
    // Parse ways
  for (var item in elements) {
    if (item['type'] == 'way' && item['tags'] != null && item['tags']['highway'] == 'steps') {
      if (item['nodes'] != null) {
        for (var nodeId in item['nodes']) {
          var node = nodes[nodeId];
          if (node != null) {
            _addMarker(LatLng(node['lat'], node['lon']), item['id'].toString(), BitmapDescriptor.defaultMarkerWithHue(90));
          }
          }
        }
      }
    }
  }

  if (markers.length > 1) {
    return false; 
  } else {
    return true; 
  }
}

LatLng _parseLatLng(String locationString) {
  List<String> coordinates = locationString.split(',');
  double lat = double.parse(coordinates[0]);
  double lon = double.parse(coordinates[1]);
  return LatLng(lat, lon);
}

// requests for distance between waypoints
Future<double> _getWalkingDistance(LatLng origin, LatLng destination) async {
  String apiKey = YOUR_API_KEY; 
  String url = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=walking&'
      'key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK') {

      //bool noStairs = await _checkStairs(origin); 


      return data['routes'][0]['legs'][0]['distance']['value'].toDouble();
    } else {
      throw Exception('Failed to fetch directions: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch directions');
  }
}

_addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  //static const maxPoint = LatLng(59.85750437916374, 17.62851763603763);
  
  //Map<MarkerId, Marker> markers = {};

  
  String googleAPiKey = YOUR_API_KEY;

  DistanceCalculator distanceCalculator = DistanceCalculator();

  @override
  void initState() {
    super.initState();

    // origin marker
    _addMarker(LatLng(start.latitude, start.longitude), "origin",
        BitmapDescriptor.defaultMarker);
  }  

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

 Future<void> _getPolyline(LatLng start) async {
  List<PolylineWayPoint> points = []; 
  //while (!inIntervall) {
  //  points = await _getWayPoints(start); 
  //}
  //TODO: for/while? ^
  for (int i = 0; i < 5; i++) {
    if (!inIntervall) {
      points = await _getWayPoints(start); 
    }
  }

  if (!inIntervall) {
    totalDistance = 'Failed'; 
    points = []; 
    reset(); 
  }


    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(start.latitude, start.longitude),
        travelMode: TravelMode.walking,
        wayPoints: points); // [PolylineWayPoint(location: "59.85750437916374,17.62851763603763"), PolylineWayPoint(location: point1.latitude.toString()+","+point1.longitude.toString())]);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

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
                initialCameraPosition: const CameraPosition(
                  zoom: 14.0,
                  target: start,
                ),  
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),              
                onMapCreated: _onMapCreated, 
                //markers: Set<Marker>.of(markers),
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
                    child: Text(totalDistance.toString(), style: const TextStyle(fontSize: 25.0)),
                  ),
                ),
              ),
            ), 
          ],
        ),
        floatingActionButton: FloatingActionButton( 
          onPressed: () async { 

            setState(() {
              reset(); 
            });

            _getPolyline(start);
            inIntervall = false;  

            //try {
            //    //List<Marker> fetchedMarkers = await fetchStairsData(markers);
            //    Map<MarkerId, Marker> fetchedMarkers = await fetchStairsData(markers);
            //    setState(() {
            //      markers = fetchedMarkers;
            //    });
            //  } catch (error) {
            //    print('Error fetching stairs data: $error');
            //  }
          },
        ),
      ),
    );
  }
}
