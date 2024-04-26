import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:flutter_config/flutter_config.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

String totalDistance = 'No Route';
bool inIntervall = false;
Map<MarkerId, Marker> markers = {};
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();

bool stairsExist = false;
String googleMapsApiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

bool natureTrail = true;

late LatLng start;

void reset() {
  markers = {};
  polylines = {};
  polylineCoordinates = [];
  polylinePoints = PolylinePoints();
  stairsExist = false;

  // Origin marker
  _addMarker(start, "origin", BitmapDescriptor.defaultMarker);
}

void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
  MarkerId markerId = MarkerId(id);
  Marker marker =
      Marker(markerId: markerId, icon: descriptor, position: position);
  markers[markerId] = marker;
}

Future<List<LatLng>> _sortPath(List<LatLng> path) async {
  List<LatLng> sortedPath = [];

  if (path.length > 0) {
    sortedPath.add(path.removeAt(0));
    print(sortedPath);

    while (path.isNotEmpty) {
      LatLng lastNode = sortedPath.last;

      List<double> distances = [];

      await Future.forEach(path, (LatLng node) async {
        double distance = await _getWalkingDistance(lastNode, node, true);
        distances.add(distance);
      });

      // Find the index of the node with the shortest distance
      int minDistanceIndex =
          distances.indexOf(distances.reduce((a, b) => a < b ? a : b));

      // Add the node with the shortest distance to the sorted list
      sortedPath.add(path[minDistanceIndex]);
      path.removeAt(minDistanceIndex);
    }
  }
  return sortedPath;
}

Future<List<LatLng>> _getPath(double radius) async {
  final url =
      'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];((way["natural"](around:${radius * 1000},${start.latitude},${start.longitude});way["leisure"="park"](around:${radius * 1000},${start.latitude},${start.longitude});way["landuse"="forest"](around:${radius * 1000},${start.latitude},${start.longitude}););(way["highway"~"^(footway|path|cycleway)"](area);););(._;>;);out;';
  final response = await http.get(Uri.parse(url));

  List<LatLng> path = [];

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    List<dynamic> elements = decoded['elements'];

    // Parse nodes
    Map<int, LatLng> nodes = {};
    for (var item in elements) {
      if (item['type'] == 'node') {
        nodes[item['id']] = LatLng(item['lat'], item['lon']);
      }
    }

    print(elements.length);
    print(elements.length - nodes.length);

    final random = Random();

    int interval = ((elements.length - nodes.length) / 10).ceil();
    int start = random.nextInt(interval) + 1;

    // Add last node of a way within each interval
    for (int i = start; i < elements.length; i += interval) {
      var item = elements[i];
      if (item['type'] == 'way') {
        List<dynamic> wayNodes = item['nodes'];
        var lastNode = wayNodes[wayNodes.length - 1];
        path.add(nodes[lastNode]!);
      }
    }
  }
  return path;
}

Future<double> _getElevation(LatLng coordinates) async {
  final url =
      'https://maps.googleapis.com/maps/api/elevation/json?locations=${coordinates.latitude},${coordinates.longitude}&key=$googleMapsApiKey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK' &&
        data['results'] != null &&
        data['results'].isNotEmpty) {
      return data['results'][0]['elevation'];
    } else {
      throw Exception('Error retrieving elevation data');
    }
  } else {
    throw Exception('Failed to load elevation data');
  }
}

Future<double> _getHilliness() async {
  print("polyListLength:");
  print(polylineCoordinates.length); // Usually about 80-150 points

  double smallestElevation = await _getElevation(polylineCoordinates[0]);
  double largestElevation = smallestElevation;

  // Increments of 10 in polyline list for suitable points
  for (int i = 1; i < polylineCoordinates.length; i += 10) {
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
  final url =
      'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];way["highway"="steps"](around:100, ${waypoint.latitude}, ${waypoint.longitude});(._;>;);out;';
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
      if (item['type'] == 'way' &&
          item['tags'] != null &&
          item['tags']['highway'] == 'steps') {
        if (item['nodes'] != null) {
          for (var nodeId in item['nodes']) {
            var node = nodes[nodeId];
            if (node != null) {
              _addMarker(
                  LatLng(node['lat'], node['lon']),
                  item['id'].toString(),
                  BitmapDescriptor.defaultMarkerWithHue(90));
            }
          }
        }
      }
    }
  }

  return markers.length > 1 ? false : true;
}

Future<double> _getWalkingDistance(
    LatLng origin, LatLng destination, bool noStairs) async {
  String url = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=walking&'
      'key=$googleMapsApiKey';

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

  double generatedDistance = 0;
  double inputDistance = 4;
  double radius = inputDistance / (pi + 2);

  print("START");
  print(start);

  if (natureTrail) {
    List<LatLng> path = await _getPath(radius);
    List<LatLng> sortedPath = await _sortPath(path);

    for (int i = 0; i < sortedPath.length - 1; i++) {
      LatLng origin = sortedPath[i];
      LatLng destination = sortedPath[i + 1];

      bool noStairs = await _checkStairs(origin);

      double distance =
          await _getWalkingDistance(origin, destination, noStairs);

      if (generatedDistance < inputDistance * 1000) {
        generatedDistance += distance;
        wayPoints.add(PolylineWayPoint(
            location: "${sortedPath[i].latitude},${sortedPath[i].longitude}"));
        _addMarker(
            LatLng(sortedPath[i].latitude, sortedPath[i].longitude),
            i.toString(),
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow));
      } else {
        break;
      }
    }

    //TODO: add points if < inputDistance * 1000 - 500
    if (generatedDistance < inputDistance * 1000 - 500) {}
  } else {
    int pointsCount = 5; //TODO: increase!
    final random = Random();
    double startDirection = random.nextDouble() * (2 * pi + 1.0);

    // Calculates each new waypoint
    for (int i = 1; i <= pointsCount; i++) {
      //double angle = (pi * i) / (2 * pointsCount) + startDirection; // Quarter circle because pi/2
      double angle =
          (pi * i) / (pointsCount) + startDirection; // Half circle because pi
      double lat = start.latitude + radius * sin(angle) / 110.574;
      double lon = start.longitude +
          radius * cos(angle) / (111.320 * cos(lat * pi / 180));

      wayPoints.add(PolylineWayPoint(location: "$lat,$lon"));
    }

    // Calculates distance between each waypoint
    for (int i = 0; i < wayPoints.length - 1; i++) {
      LatLng origin = _parseLatLng(wayPoints[i].location);
      LatLng destination = _parseLatLng(wayPoints[i + 1].location);

      bool noStairs = await _checkStairs(origin);

      double distance =
          await _getWalkingDistance(origin, destination, noStairs);

      generatedDistance += distance;
    }
  }
  print("GENERATED DISTANCE:");
  print(generatedDistance);

  // Removes last points if distans is too long
  while (generatedDistance > inputDistance * 1000 + 500) {
    LatLng origin = _parseLatLng(wayPoints[wayPoints.length - 2].location);
    LatLng destination = _parseLatLng(wayPoints[wayPoints.length - 1].location);

    bool noStairs = await _checkStairs(origin);

    double distance = await _getWalkingDistance(origin, destination, noStairs);

    wayPoints.removeAt(wayPoints.length - 1);
    generatedDistance -= distance;
    print("REMOVED DISTANCE: ");
    print(distance);
  }

  if (generatedDistance > inputDistance * 1000 - 500 &&
      generatedDistance < inputDistance * 1000 + 500) {
    inIntervall = true;
    totalDistance = generatedDistance
        .toString(); //TODO: place somewhere useful when such exists
  }

  return wayPoints;
}

void _addPolyLine() {
  PolylineId id = PolylineId("poly");
  Polyline polyline =
      Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
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
    googleMapsApiKey,
    PointLatLng(start.latitude, start.longitude),
    PointLatLng(start.latitude, start.longitude),
    travelMode: TravelMode.walking,
    wayPoints: points,
  );
  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
  }
  _addPolyLine();
}

class GeneratedMap extends StatelessWidget {
  const GeneratedMap({Key? key}) : super(key: key);

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
  const MapsRoutesExample({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MapsRoutesExampleState createState() => _MapsRoutesExampleState();
}

class _MapsRoutesExampleState extends State<MapsRoutesExample> {
  late Completer<GoogleMapController> _controller = Completer();

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14));
  }

  @override
  void initState() {
    super.initState();

    // Get current location
    _getLocation();
  }

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        start = LatLng(position.latitude, position.longitude);
        _addMarker(start, "origin", BitmapDescriptor.defaultMarker);
        _asyncMethod();
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  _asyncMethod() async {
    await _getPolyline(start);

    setState(() {});

    double hillines =
        await _getHilliness(); //TODO: place somewhere useful when such exists
    print("Total Hilliness:");
    print(hillines);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              initialCameraPosition: CameraPosition(
                zoom: 14.0,
                target: LatLng(start.latitude, start.longitude),
              ),
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
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
                  child: Text(totalDistance.toString(),
                      style: const TextStyle(fontSize: 25.0)),
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
          centerScreen(await Geolocator.getCurrentPosition());

          setState(() {});

          double hillines = await _getHilliness();
          print("Total Hilliness:");
          print(hillines);
        },
      ),
    );
  }
}
