import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:flutter_config/flutter_config.dart';
import 'package:geofence_service/geofence_service.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:trailquest/main.dart';

String totalDistance = 'No Route';
bool inIntervall = false;
Map<MarkerId, Marker> markers = {};
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();

bool stairsExist = false;
String googleMapsApiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

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

  for (int i = 1; i < polylineCoordinates.length; i += 10) {
    // Increments of 10 in polyline list
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

  const routeLength = 2;
  const radius = routeLength;

  wayPoints
      .add(PolylineWayPoint(location: "${start.latitude},${start.longitude}"));
  print(start);

  int pointsCount = 1; //TODO: increase!
  final random = Random();
  double startDirection = random.nextDouble() * (2 * pi + 1.0);

  double routeDistance = 0;

  // Calculates each new waypoint
  for (int i = 1; i <= pointsCount; i++) {
    double angle = (pi * i) / (2 * pointsCount) + startDirection;
    double lat = start.latitude + radius * sin(angle) / 110.574;
    double long =
        start.longitude + radius * cos(angle) / (111.320 * cos(lat * pi / 180));

    wayPoints.add(PolylineWayPoint(location: "$lat,$long"));
  }

  // Calculates distance between each waypoint
  for (int i = 0; i < wayPoints.length - 1; i++) {
    LatLng origin = _parseLatLng(wayPoints[i].location);
    LatLng destination = _parseLatLng(wayPoints[i + 1].location);

    bool noStairs = await _checkStairs(origin);

    double distance = await _getWalkingDistance(origin, destination, noStairs);

    print("Distance between waypoint $i and ${i + 1}: $distance meters");
    routeDistance += distance;
  }

  print(routeDistance);

  if (routeDistance > routeLength * 1000 - 500 &&
      routeDistance < routeLength * 1000 + 500) {
    // +- 500m //TODO: edit!
    inIntervall = true;
    totalDistance = routeDistance
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

Future<PolylineResult> _getPolyline(LatLng start) async {
  List<PolylineWayPoint> points = [];
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

  // If failed will use the last generated route
  if (!inIntervall) {
    print("Found no route");
    totalDistance = 'Failed';
    points = [];
    reset();
  }

  // Circle
  // From start to start through points generated
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

  return result;
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
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();
  late Completer<GoogleMapController> _controller = Completer();

  int activeIndex = 0;

  final _geofenceService = GeofenceService.instance.setup(
      interval: 2000,
      accuracy: 10,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: true,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 15));
  }

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();

    // Get current location
    _getLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start().catchError(_onError);
    });
    // _geofenceService.addGeofence(Geofence(
    //     id: "loc_$activeIndex",
    //     latitude: points[activeIndex].latitude,
    //     longitude: points[activeIndex].longitude,
    //     radius: [GeofenceRadius(id: "radius_10m", length: 10)]));
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
    PolylineResult result = await _getPolyline(start);

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

          PolylineResult result = await _getPolyline(start);
          _addMarker(
              LatLng(result.points[(result.points.length / 2).round()].latitude,
                  result.points[(result.points.length / 2).round()].longitude),
              "Last",
              BitmapDescriptor.defaultMarkerWithHue(50));
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
