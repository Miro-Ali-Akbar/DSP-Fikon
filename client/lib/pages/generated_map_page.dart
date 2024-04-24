import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:math'; 

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; 

// import 'api_key.dart'; 

String totalDistance = 'No Route'; 
bool inIntervall = false; 
Map<MarkerId, Marker> markers = {};
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();
bool stairsExist = false; 

String googleAPiKey = 'YOUR_API_KEY';

const start = LatLng(59.85444306179348, 17.63943133739685);

void reset() {
  markers = {}; 
  polylines = {};
  polylineCoordinates = [];
  polylinePoints = PolylinePoints();
  stairsExist = false; 
  
  //origin marker
    _addMarker(LatLng(start.latitude, start.longitude), "origin",
        BitmapDescriptor.defaultMarker);
}

_addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
}

//fetches elevation of a coordinate
Future<double> _getElevation(LatLng coordinates) async {
    final apiKey = 'YOUR-API-KEY';
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

Future<double> _getHilliness() async {
  print("polyListLength:"); 
  print(polylineCoordinates.length); //ususally about 80-150 points

  double smallestElevation = await _getElevation(polylineCoordinates[0]);
  double largestElevation = smallestElevation;

  for (int i = 1; i < polylineCoordinates.length; i += 10) { //increments of 10 in polyline list
    double elevation = await _getElevation(polylineCoordinates[i]);
    if (elevation < smallestElevation) {
      smallestElevation = elevation;
    }
    if (elevation > largestElevation) {
      largestElevation = elevation;
    }
  }

  print('Smallest Elevation: $smallestElevation');
  print('Largest Elevation: $largestElevation');

  return largestElevation - smallestElevation; 
}

Future<bool> _checkStairs(LatLng waypoint) async {
  final url = 'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];way["highway"="steps"](around:100, ${waypoint.latitude}, ${waypoint.longitude});(._;>;);out;';  
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    List<dynamic> elements = decoded['elements'];

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

// requests for distance between waypoints
Future<double> _getWalkingDistance(LatLng origin, LatLng destination, bool noStairs) async {
  String apiKey = 'YOUR-API-KEY'; 
  String url = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=walking&'
      'key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK') {

      if (!noStairs) {

          // Search for the phrase in html_instructions field
          for (var route in data['routes']) {
            for (var leg in route['legs']) {
              for (var step in leg['steps']) {
                if (step['html_instructions'] != null &&
                    step['html_instructions'].contains('stairs')) {
                  print(step['html_instructions']); 
                  stairsExist = true;
                  break;
                }
              }
              if (stairsExist) break;
            }
            if (stairsExist) break;
          }
          print(stairsExist); 
      }

      return data['routes'][0]['legs'][0]['distance']['value'].toDouble();

    } else {
      throw Exception('Failed to fetch directions: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch directions');
  }
}

LatLng _parseLatLng(String locationString) {
  List<String> coordinates = locationString.split(',');
  double lat = double.parse(coordinates[0]);
  double lon = double.parse(coordinates[1]);
  return LatLng(lat, lon);
}

Future<List<PolylineWayPoint>> _getWayPoints(LatLng start) async {
    List<PolylineWayPoint> wayPoints = [];

    const routeLength = 4; 
    const radius = routeLength / (pi + 2); 

    wayPoints.add(PolylineWayPoint(location: "${start.latitude},${start.longitude}"));
    print(start); 

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

  //LatLng guaranteedStairs = LatLng(59.85484782098098,17.64208456717594); 
  //wayPoints.add(PolylineWayPoint(location: "59.85484782098098,17.64208456717594")); //test point with guaranteed stairs

  // calculates distance between each waypoint
  for (int i = 0; i < wayPoints.length - 1; i++) {
    LatLng origin = _parseLatLng(wayPoints[i].location);
    LatLng destination = _parseLatLng(wayPoints[i + 1].location);

    //LatLng origin = start; 
    //LatLng destination = guaranteedStairs; 

    bool noStairs = await _checkStairs(origin);

    double distance = await _getWalkingDistance(origin, destination, noStairs);

    print("Distance between waypoint $i and ${i + 1}: $distance meters");
    routeDistance += distance; 
  }

  print(routeDistance); 
 
  if (routeDistance > routeLength * 1000 - 2000 && routeDistance < routeLength * 1000 + 2000) { //+- 500m //TODO: edit!
    inIntervall = true; 
    totalDistance = routeDistance.toString(); //TODO: place somewhere useful when such exists
  } 

  return wayPoints;
}

_addPolyLine() {
 PolylineId id = PolylineId("poly");
 Polyline polyline = Polyline(
     polylineId: id, color: Colors.red, points: polylineCoordinates);
 polylines[id] = polyline;
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

    if (stairsExist) {
      print("STAIRS FOUND ON ROUTE, RETRYING..."); 
      stairsExist = false; 
      inIntervall = false; 
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


class Genreated_map extends StatelessWidget {
  const Genreated_map({super.key});

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
  
  DistanceCalculator distanceCalculator = DistanceCalculator();

  @override
  void initState() {
    super.initState();

    // origin marker
    _addMarker(LatLng(start.latitude, start.longitude), "origin",
        BitmapDescriptor.defaultMarker);

    _asyncMethod(); 
  }

  _asyncMethod() async {
    await _getPolyline(start);

    setState(() {});
            
    double hillines = await _getHilliness(); //TODO: place somewhere useful when such exists
    print("Total Hilliness:"); 
    print(hillines); 
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
                    child: Text(totalDistance.toString(), style: const TextStyle(fontSize: 25.0)), //totalDistance for the route
                  ),
                ),
              ),
            ), 
          ],
        ),
        floatingActionButton: FloatingActionButton.extended( 
          label: Text("Retry?"),
          onPressed: () async { 

            setState(() {
              reset(); 
            });

            inIntervall = false;  
            stairsExist = false;

            await _getPolyline(start);

            setState(() {}); 

            double hillines = await _getHilliness(); 
            print("Total Hilliness:"); 
            print(hillines); 
          },
        ), 
      ),
    );
  }
}