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

void main() {
  runApp(const MyApp());
}


Future<List<PolylineWayPoint>> _getWayPoints(LatLng start) async {
    List<PolylineWayPoint> wayPoints = [];

    const routeLength = 4; 
    const radius = routeLength / (pi + 2); 

    wayPoints.add(PolylineWayPoint(location: "${start.latitude},${start.longitude}"));

    int pointsCount = 10; 
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
    double distance = await _getWalkingDistance(origin, destination);

    print("Distance between waypoint $i and ${i + 1}: $distance meters");
    routeDistance += distance; 
  }

  print(routeDistance); 
 
  if (routeDistance > routeLength * 1000 - 500 && routeDistance < routeLength * 1000 + 500) { //+- 500m
    inIntervall = true; 
    totalDistance = routeDistance.toString(); 
  } 

  return wayPoints;
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
      return data['routes'][0]['legs'][0]['distance']['value'].toDouble();
    } else {
      throw Exception('Failed to fetch directions: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch directions');
  }
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

  static const start = LatLng(59.85444306179348, 17.63943133739685);
  //static const maxPoint = LatLng(59.85750437916374, 17.62851763603763);
  
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = YOUR_API_KEY;

  DistanceCalculator distanceCalculator = DistanceCalculator();

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(start.latitude, start.longitude), "origin",
        BitmapDescriptor.defaultMarker);
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
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
            _getPolyline(start); 
          },
        ),
      ),
    );
  }
}
