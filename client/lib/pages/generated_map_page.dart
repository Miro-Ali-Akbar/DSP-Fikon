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

import 'generate_trail_page.dart';

import 'package:flutter_svg/svg.dart';
import 'package:trailquest/widgets/trail_cards.dart';
import '../widgets/back_button.dart';

//String totalDistance = 'No Route';
double totalDistance = 0;
bool inIntervall = false;
Map<MarkerId, Marker> markers = {};
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();
Map<String, double> distanceCache = {};

bool stairsExist = false;
String googleMapsApiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

String activityOption = '';

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

    while (path.isNotEmpty) {
      LatLng lastNode = sortedPath.last;

      List<double> distances = [];

      for (int i = 0; i < path.length; i++) {
        double distance;
        String key =
            '${lastNode.latitude},${lastNode.longitude}-${path[i].latitude},${path[i].longitude}';
        if (distanceCache.containsKey(key)) {
          distance = distanceCache[key]!;
        } else {
          distance = await _getWalkingDistance(lastNode, path[i], true);
          distanceCache[key] = distance;
        }
        distances.add(distance);
      }

      // Find the index of the minimum distance
      int minDistanceIndex =
          distances.indexOf(distances.reduce((a, b) => a < b ? a : b));

      sortedPath.add(path[minDistanceIndex]);
      path.removeAt(minDistanceIndex);
    }
  }
  return sortedPath;
}

Future<List<LatLng>> _getPath(double radius) async {
  final url =
      'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];((way["natural"](around:${radius},${start.latitude},${start.longitude});way["leisure"="park"](around:${radius},${start.latitude},${start.longitude});way["landuse"="forest"](around:${radius},${start.latitude},${start.longitude}););(way["highway"~"^(footway|path|cycleway)"](area);););(._;>;);out;';
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
  String key =
      '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';

  if (distanceCache.containsKey(key)) {
    return distanceCache[key]!;
  }

  if (activityOption == 'Running') {
    activityOption = 'walking';
  }

  if (activityOption == 'Cycling') {
    activityOption = 'bicycling ';
  }

  String url = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=${activityOption.toLowerCase()}&'
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

      double distance =
          data['routes'][0]['legs'][0]['distance']['value'].toDouble();

      // Cache the distance
      distanceCache[key] = distance;

      return distance;
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

Future<List<PolylineWayPoint>> _getWayPoints(
    LatLng start, double inputDistance, bool statusEnvironment) async {
  List<PolylineWayPoint> wayPoints = [];

  double generatedDistance = 0;
  double radius = inputDistance / (pi + 2); //m
  double radiusKM = radius / 1000; //km

  print("START");
  print(start);

  if (statusEnvironment) {
    List<LatLng> path = await _getPath(radius);
    List<LatLng> sortedPath = await _sortPath(path);

    for (int i = 0; i < sortedPath.length - 1; i++) {
      LatLng origin = sortedPath[i];
      LatLng destination = sortedPath[i + 1];

      bool noStairs = await _checkStairs(origin);

      double distance =
          await _getWalkingDistance(origin, destination, noStairs);

      if (generatedDistance < inputDistance) {
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

    //TODO: add points if < inputDistance - 500
    if (generatedDistance < inputDistance - 500) {}
  } else {
    int pointsCount = 5; //TODO: increase!
    final random = Random();
    double startDirection = random.nextDouble() * (2 * pi + 1.0);

    // Calculates each new waypoint
    for (int i = 1; i <= pointsCount; i++) {
      double angle =
          (pi * i) / (pointsCount) + startDirection; // Half circle because pi
      double lat = start.latitude + radiusKM * sin(angle) / 110.574;
      double lon = start.longitude +
          radiusKM * cos(angle) / (111.320 * cos(lat * pi / 180));

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
  while (generatedDistance > inputDistance + 500) {
    LatLng origin = _parseLatLng(wayPoints[wayPoints.length - 2].location);
    LatLng destination = _parseLatLng(wayPoints[wayPoints.length - 1].location);

    bool noStairs = await _checkStairs(origin);

    double distance = await _getWalkingDistance(origin, destination, noStairs);

    wayPoints.removeAt(wayPoints.length - 1);
    generatedDistance -= distance;
    print("REMOVED DISTANCE: ");
    print(distance);
  }

  if (generatedDistance > inputDistance - 500 &&
      generatedDistance < inputDistance + 500) {
    inIntervall = true;
    totalDistance = generatedDistance;
  }

  return wayPoints;
}

void _addPolyLine() {
  PolylineId id = PolylineId("poly");
  Polyline polyline =
      Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
  polylines[id] = polyline;
}

Future<void> _getPolyline(LatLng start, double inputDistance,
    bool statusEnvironment, bool avoidStairs) async {
  List<PolylineWayPoint> points = [];
  //while (!inIntervall) {
  //  points = await _getWayPoints(start);
  //}
  //TODO: for/while? ^
  for (int i = 0; i < 5; i++) {
    if (!inIntervall) {
      points = await _getWayPoints(start, inputDistance, statusEnvironment);
    }

    if (stairsExist && avoidStairs) {
      print("STAIRS FOUND ON ROUTE, RETRYING...");
      stairsExist = false;
      inIntervall = false;
      points = await _getWayPoints(start, inputDistance, statusEnvironment);
    }
  }

  if (!inIntervall) {
    points = await _getWayPoints(start, inputDistance + 500, statusEnvironment);
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
  GeneratedMap({Key? key}) : super(key: key);

  TrailCard trail = TrailCard(
      name: '',
      lengthDistance: 0,
      lengthTime: 0,
      natureStatus: '',
      stairs: false,
      heightDifference: 0,
      isSaved: false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Routes Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const MapsRoutesExample(title: 'GMR Demo Home'),
      home: MapsRoutesGenerator(
          trail: trail, saved: false, onSaveChanged: (value) {}),
    );
  }
}

class MapsRoutesGenerator extends StatefulWidget {
  TrailCard trail;
  bool saved;
  final ValueChanged<bool> onSaveChanged; // Callback function

  MapsRoutesGenerator({
    Key? key,
    required this.trail,
    required this.saved,
    required this.onSaveChanged, // Callback function
  }) : super(key: key);

  @override
  State<MapsRoutesGenerator> createState() =>
      _MapsRoutesGeneratorState(trail: trail, saved: saved);
}

class _MapsRoutesGeneratorState extends State<MapsRoutesGenerator> {
  bool saved = false;
  TrailCard trail;

  _MapsRoutesGeneratorState(
      {Key? key, required this.trail, required this.saved});

  late Completer<GoogleMapController> _controller = Completer();

  double inputDistance = 0;
  bool generateCircleRoute = false;
  bool userStartPoint = false;
  bool statusEnvironment = false;
  bool avoidStairs = false;

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude), 14));
  }

  @override
  void initState() {
    super.initState();
    activityOption =
        getSelectedActivity(); //'Walking', 'Running', 'Cycling' //global
    generateCircleRoute = getSelectedTrailType() ==
            'assets/images/img_circular_arrow.svg'
        ? true
        : false; //'assets/images/img_circular_arrow.svg', 'assets/images/img_route.svg' //TODO: startpoint != endpoint not implemented
    userStartPoint = getSelectedStatusStartPoint() == 'Yes'
        ? true
        : false; //'Yes', 'No (choose from map)' //TODO: 'No' not implemented
    statusEnvironment = getSelectedStatusEnvironment() == 'Nature'
        ? true
        : false; //'Nature', 'City', 'Both'
    avoidStairs = getCheckedValue();
    inputDistance = double.parse(getInputDistance());

    if (!getIsDistanceMeters()) {
      inputDistance = inputDistance * 60 * 1.42;
    }

    // Get current location
    _getLocation(inputDistance);
  }

  void _getLocation(double inputDistance) async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        start = LatLng(position.latitude, position.longitude);
        _addMarker(start, "origin", BitmapDescriptor.defaultMarker);
      });
      await _asyncMethod(inputDistance);
      setState(() {
        _buildTrailCard();
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  double hillines = 0;

  _asyncMethod(double inputDistance) async {
    await _getPolyline(start, inputDistance, statusEnvironment, avoidStairs);

    setState(() {});

    hillines = await _getHilliness();
    print("Total Hilliness:");
    print(hillines);
  }

  double _distanceToTime(double distance) {
    if (activityOption == 'Walking') {
      return distance / 1.42 / 60;
    } else if (activityOption == 'Running') {
      return distance / 2.56 / 60;
    } else {
      return distance / 5.0 / 60;
    }
  }

  void _buildTrailCard() {
    trail.name = 'Your Trail';
    trail.stairs = !avoidStairs;
    trail.lengthDistance = totalDistance;
    trail.lengthTime =
        double.parse((_distanceToTime(totalDistance)).toStringAsFixed(1));
    trail.natureStatus = getSelectedStatusEnvironment();
    trail.heightDifference = double.parse((hillines).toStringAsFixed(1));
    trail.isSaved = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Column(children: [
        Row(
          children: [
            GoBackButton(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text('${trail.name}', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        Expanded(
          child: Center(
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
        ),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/img_walking.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      height: 35,
                      width: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        '${trail.lengthDistance / 1000} km',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/img_clock.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      height: 35,
                      width: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        '${trail.lengthTime} min',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/img_trees.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      height: 35,
                      width: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        '${trail.natureStatus}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/img_stairs.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      height: 35,
                      width: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        trail.stairs
                            ? 'This route could contain stairs'
                            : 'This route does not contain any stairs',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/img_arrow_up.svg',
                      colorFilter:
                          ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      height: 35,
                      width: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        '${trail.heightDifference} m',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    if (saved) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: RemoveTrail(
                          onRemove: (value) {
                            setState(() {
                              saved = value;
                              widget.onSaveChanged(false);
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!saved) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: SaveTrail(
              onSave: (value) {
                setState(() {
                  saved = value;
                  widget.onSaveChanged(true);
                });
              },
            ),
          ),
        ],
      ])),
    );
  }
}

class SaveTrail extends StatefulWidget {
  final Function(bool) onSave;

  const SaveTrail({Key? key, required this.onSave}) : super(key: key);
  @override
  State<SaveTrail> createState() => _SaveTrailState();
}

class _SaveTrailState extends State<SaveTrail> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget.onSave(true);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Save Trail +',
          style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }
}

class RemoveTrail extends StatefulWidget {
  final Function(bool) onRemove;

  const RemoveTrail({Key? key, required this.onRemove}) : super(key: key);

  @override
  State<RemoveTrail> createState() => _RemoveTrailState();
}

class _RemoveTrailState extends State<RemoveTrail> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget.onRemove(false);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Remove Trail',
          style: TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}
