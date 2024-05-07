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
import 'package:trailquest/pages/map_page.dart';

import 'generate_trail_page.dart';

import 'package:flutter_svg/svg.dart';
import 'package:trailquest/widgets/trail_cards.dart';
import '../widgets/back_button.dart';

double totalDistance = 0;
bool inIntervall = false;
Map<MarkerId, Marker> markers = {};
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
PolylinePoints polylinePoints = PolylinePoints();
bool stairsExist = false;
String activityOption = '';

Map<String, double> distanceCache = {};

String googleMapsApiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

// Constants to determine the speed of different activities
double walkingSpeed = 1.42;
double runningSpeed = 2.56;
double cyclingSpeed = 5.0;

late LatLng start;

/// Resets global variables used by generated_map_page
void reset() {
  totalDistance = 0;
  inIntervall = false;
  markers = {};
  polylines = {};
  polylineCoordinates = [];
  polylinePoints = PolylinePoints();
  stairsExist = false;
  activityOption = '';
}

/// Adds a marker to the list of markers the map will display
///
/// [position] the coordinates of the marker
/// [id] an identifier for the marker
/// [descriptor] used to set the image of the marker
void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
  MarkerId markerId = MarkerId(id);
  Marker marker =
      Marker(markerId: markerId, icon: descriptor, position: position);
  markers[markerId] = marker;
}

/// Sorts a list of coordinates based on walking distance.
///
/// Given a list of LatLng points representing a path, this function sorts
/// the path by minimizing the walking distance between consecutive points.
///
/// Example: The second element in the list is the coordinate which has the
/// shortest walking/running/cycling distance to the first coordinate out
/// of all elements.
///
/// [path] the list of coordinates to be sorted
///
/// Returns a sorted list of LatLng points
Future<List<LatLng>> _sortPath(List<LatLng> path) async {
  List<LatLng> sortedPath = [];

  if (path.length > 0) {
    sortedPath.add(path.removeAt(0));

    while (path.isNotEmpty) {
      LatLng lastNode = sortedPath.last;

      List<double> distances = [];

      // Calculates (or finds) the (cached) walking distance between the last node and
      // each point in the remaining path, storing the distances in a list for further processing.
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

/// Fetches a path of LatLng points from OpenStreetMap within a specified radius.
///
/// Queries OpenStreetMap's Overpass API for natural features like parks, forests,
/// and footways near the starting point, based on the given [radius].
///
/// Independently of the number of elements the query returns a path of 10 coordinates.
///
/// [radius] the search radius (in meters) around the starting point.
///
/// Returns list of LatLng points representing the path.
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

    // A random number is chosen whithin the length of a interval to be the offset for each interval
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

/// Fetches the elevation of a set of coordinates from Google Maps
///
/// [coordinates] the set of coordinates fo find the elevation of.
///
/// Returns the height (over sea level) for the set of coordinates.
///
/// Throws an [Exception] if there was an error in fetching or loading the data.
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

/// Calculates the difference in height of a route based on elevation data.
///
/// Returns the height difference between the point with the smallest elevation and the largest.
Future<double> _getHilliness() async {
  print("polyListLength:");
  print(polylineCoordinates.length); // Usually about 80-150 points

  double smallestElevation = await _getElevation(polylineCoordinates[0]);
  double largestElevation = smallestElevation;

  // Increments of 10 in polyline list for suitable points
  // Identifies the points with the smallest and largest elevation
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

/// Checks if there are stairs around 100m of a coordinate.
///
/// Checks if there are stairs near the specified waypoint.
///
/// Queries OpenStreetMap to search for highway steps within
/// a 100-meter radius of the given [waypoint]. (TODO: Remove?: If stairs are found, markers
/// are added to the map to indicate their locations.)
///
/// [waypoint] the coordinate to check for stairs.
///
/// Returns true if no stairs are found near the waypoint, and false otherwise.
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

/// Retrieves the walking/running/cycling distance between the origin and destination coordinates.
///
/// Uses the Google Maps Directions API to calculate the walking distance
/// between the specified [origin] and [destination] coordinates.
///
/// [origin] the LatLng coordinate representing the starting point.
/// [destination] the LatLng coordinate representing the destination point.
/// [noStairs] a boolean indicating whether stairs are on or in the vicinity of the route.
///
/// Returns the walking distance in meters between the origin and destination.
///
/// Trows [Exception] if an error occcurs when fetching the directions.
Future<double> _getWalkingDistance(
    LatLng origin, LatLng destination, bool noStairs) async {
  String key =
      '${origin.latitude},${origin.longitude}-${destination.latitude},${destination.longitude}';

  if (distanceCache.containsKey(key)) {
    return distanceCache[key]!;
  }

  String distanceActivityOption;
  switch (activityOption) {
    case 'Walking':
      distanceActivityOption = 'walking';
      break;
    case 'Running':
      distanceActivityOption = 'walking';
      break;
    case 'Cycling':
      distanceActivityOption = 'bicycling';
      break;
    default:
      distanceActivityOption = '';
      print("Activity unrecognized!");
      print("Nothing set!");
  }

  String url = 'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'mode=${distanceActivityOption.toLowerCase()}&'
      'key=$googleMapsApiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK') {
      // If the check for possible stairs returns true then the instructions of the
      // route are searched to establish if they are exactly on the route
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

/// Parses a string of coordinates into a LatLng object.
///
/// [locationString] the sting to parse.
///
/// Returns a LatLng of coordinates from [locationString].
LatLng _parseLatLng(String locationString) {
  List<String> coordinates = locationString.split(',');
  double lat = double.parse(coordinates[0]);
  double lon = double.parse(coordinates[1]);
  return LatLng(lat, lon);
}

/// Retrieves a list of polyline waypoints for a given starting point and distance.
///
/// Calculates polyline waypoints based on the specified [start] point and [inputDistance].
///
/// If [statusEnvironment] is true, it generates waypoints along a path obtained from
/// OpenStreetMap data, considering environmental factors - the nature route generation.
/// Otherwise, it generates waypoints in a circular pattern around the starting point - the
/// normal route generation.
///
/// [start] the LatLng coordinate representing the starting point.
/// [inputDistance] the distance (in meters) for which waypoints are generated.
/// [statusEnvironment] a boolean indicating whether to consider a natura favored route.
///
/// Returns a list of polyline waypoints.
Future<List<PolylineWayPoint>> _getWayPoints(
    LatLng start, double inputDistance, bool statusEnvironment) async {
  List<PolylineWayPoint> wayPoints = [];

  double generatedDistance = 0;
  double radius = inputDistance / (pi + 2); //m
  double radiusKM = radius / 1000; //km

  print("START");
  print(start);

  // Nature favored route generation if chosen, else normal generation
  if (statusEnvironment) {
    List<LatLng> path = await _getPath(radius);
    List<LatLng> sortedPath = await _sortPath(path);

    for (int i = 0; i < sortedPath.length - 1; i++) {
      LatLng origin = sortedPath[i];
      LatLng destination = sortedPath[i + 1];

      bool noStairs = await _checkStairs(origin);

      double distance =
          await _getWalkingDistance(origin, destination, noStairs);

      // Add waypoint and distance if the input distance hasn't been reached
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
    int pointsCount = 10; //TODO: increase!
    final random = Random();
    double startDirection = random.nextDouble() * (2 * pi + 1.0);

    // Calculates each new waypoint on a half circle, taking roughly consideration of the earths curvature
    for (int i = 1; i <= pointsCount; i++) {
      double angle = (pi * i) / (pointsCount) + startDirection;
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

  // Removes last points if the generated distance is to long
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

  // Check if the generated route is within an interval of what the user requested
  if (generatedDistance > inputDistance - 500 &&
      generatedDistance < inputDistance + 500) {
    inIntervall = true;
    totalDistance = generatedDistance;
  }

  return wayPoints;
}

/// Creates a polyline with id, color and coordinates
void _addPolyLine() {
  PolylineId id = PolylineId("poly");
  Polyline polyline =
      Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
  polylines[id] = polyline;
}

/// Retrieves and draws a polyline route on the map.
///
/// [start] the LatLng coordinate representing the starting point.
/// [inputDistance] the distance (in meters) for generating waypoints.
/// [statusEnvironment] a boolean indicating whether to favor nature.
/// [avoidStairs] a boolean indicating whether to avoid routes with stairs.
Future<void> _getPolyline(LatLng start, double inputDistance,
    bool statusEnvironment, bool avoidStairs) async {
  List<PolylineWayPoint> points = [];

  int increaseRoute = 0;
  // Five tries to generate an acceptable route, each try increases the distance
  for (int i = 0; i < 5; i++) {
    if (!inIntervall) {
      points = await _getWayPoints(
          start, inputDistance + increaseRoute, statusEnvironment);
    }

    // If stairs exist on the route and the user requested no stairs the route generation is retried
    if (stairsExist && avoidStairs) {
      print("STAIRS FOUND ON ROUTE, RETRYING...");
      stairsExist = false;
      inIntervall = false;
      points = await _getWayPoints(start, inputDistance, statusEnvironment);
    }

    increaseRoute += 500;
  }

  // TODO: Error handling if route generation failed
  if (!inIntervall) {
    print("ERROR IN GENERATING ROUTE");
    points = [];
    reset();
  }

  // Creates polyline from start to start through the generated points
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleMapsApiKey,
    PointLatLng(start.latitude, start.longitude),
    PointLatLng(start.latitude, start.longitude),
    travelMode: TravelMode.walking,
    wayPoints: points,
  );

  // Adds the point to the object used by the map to display the polyline
  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
  }
  _addPolyLine();
}

/// Calculates how long it would take to walk/run/cycle a distance,
/// based on average speeds for the categories.
///
/// [distance] the distance to convert to time.
///
/// Returns the time in minutes it would take to travel the distance.
double _distanceToTime(double distance) {
  print("Activity option == $activityOption");
  switch (activityOption) {
    case 'Walking':
      return distance / walkingSpeed / 60;
    case 'Running':
      return distance / runningSpeed / 60;
    case 'Cycling':
      return distance / cyclingSpeed / 60;
    default:
      // If not walking/running/cycling a default value is used
      double defaultTime = distance / 60;
      print("Activity unrecognized!");
      print("Time set to $defaultTime");
      return defaultTime;
  }
}

/// A StatelessWidget that displays a generated map.
///
/// Displays a generated map using the MapsRoutesGenerator widget,
/// configured with a default TrailCard and options to save the route.
class GeneratedMap extends StatelessWidget {
  GeneratedMap({Key? key}) : super(key: key);

  TrailCard trail = TrailCard(
    name: '',
    lengthDistance: 0,
    lengthTime: 0,
    natureStatus: '',
    stairs: false,
    heightDifference: 0,
    isSaved: false,
    isCircular: false,
    coordinates: [],
    image_path: '',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps Routes Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapsRoutesGenerator(
          trail: trail, saved: false, onSaveChanged: (value) {}),
    );
  }
}

/// A StatefulWidget for generating maps routes.
///
/// This widget allows the generation of map routes based on the provided [trail],
/// [saved] status, and a callback function [onSaveChanged] to handle save state changes.
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

/// The state for the MapsRoutesGenerator widget.
///
/// Manages the state of the map generation process, including user options,
/// location retrieval, polyline generation, and UI updates.
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
    // Resets all global variables
    reset();

    // Fetches the users input data to use as filters for the route generation
    activityOption =
        getSelectedActivity(); //'Walking', 'Running', 'Cycling' //global
    generateCircleRoute = getSelectedTrailType() ==
            'assets/icons/img_circular_arrow.svg'
        ? true
        : false; //'assets/icons/img_circular_arrow.svg', 'assets/icons/img_route.svg' //TODO: startpoint != endpoint not implemented
    userStartPoint = getSelectedStatusStartPoint() == 'Yes'
        ? true
        : false; //'Yes', 'No (choose from map)'
    statusEnvironment = getSelectedStatusEnvironment() == 'Nature'
        ? true
        : false; //'Nature', 'City', 'Both'
    avoidStairs = getCheckedValue();
    inputDistance = double.parse(getInputDistance());

    // Time in meters
    if (!getIsDistanceMeters()) {
      switch (activityOption) {
        case 'Walking':
          inputDistance = inputDistance * walkingSpeed * 60;
          break;
        case 'Running':
          inputDistance = inputDistance * runningSpeed * 60;
          break;
        case 'Cycling':
          inputDistance = inputDistance * cyclingSpeed * 60;
          break;
        default:
          print("Activity unrecognized!");
          print("inputDistance untouched");
          inputDistance = inputDistance * 60;
      }
    }

    // Get current location
    _getLocation(inputDistance);
  }

  /// Retrieves the current location and initiates map generation.
  ///
  /// Retrieves the current device location using Geolocator. If [userStartPoint]
  /// is true, sets the starting point as the current location. Otherwise, uses the
  /// picked location. Adds a marker to the map at the starting point. Initiates the
  /// generation of the map route asynchronously using the [_asyncMethod]. Updates the
  /// UI to display the generated trail card.
  ///
  /// [inputDistance] the distance (in meters) for generating waypoints.
  void _getLocation(double inputDistance) async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        if (userStartPoint) {
          start = LatLng(position.latitude, position.longitude);
          _addMarker(start, "origin", BitmapDescriptor.defaultMarker);
        } else {
          start = getPickedLocation();
          _addMarker(start, "origin", BitmapDescriptor.defaultMarker);
        }
      });
      await _asyncPolylineandHilliness(inputDistance);
      setState(() {
        _buildTrailCard();
      });
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  double hillines = 0;

  /// Asynchronously generates the polyline route and calculates hilliness.
  ///
  /// Generates the polyline route asynchronously using the [_getPolyline] method
  /// based on the provided [start] point, [inputDistance], [statusEnvironment], and
  /// [avoidStairs]. Updates the UI to reflect the generated route. Calculates the
  /// hilliness of the route asynchronously using the [_getHilliness] method.
  ///
  /// [inputDistance] the distance (in meters) for generating waypoints.
  Future<void> _asyncPolylineandHilliness(double inputDistance) async {
    await _getPolyline(start, inputDistance, statusEnvironment, avoidStairs);

    setState(() {});

    hillines = await _getHilliness();
    print("Total Hilliness:");
    print(hillines);
  }

  // Builds the trailcard based on the generated route
  // The trailcard is used as reference for displaying the data
  void _buildTrailCard() {
    trail.name = 'Your Trail';
    trail.stairs = !avoidStairs;
    trail.lengthDistance = totalDistance;
    trail.lengthTime =
        double.parse((_distanceToTime(totalDistance)).toStringAsFixed(1));
    trail.natureStatus = getSelectedStatusEnvironment();
    trail.heightDifference = double.parse((hillines).toStringAsFixed(1));
    trail.isSaved = false;
    trail.coordinates = polylineCoordinates;
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
            child: GestureDetector(
              child: Container(
                child: Stack(
                  children: [
                    GoogleMap(
                      onTap: (_) {
                        Navigator.of(context, rootNavigator: true)
                            .push(PageRouteBuilder(
                          pageBuilder: (context, x, xx) => MapPage(trail: trail),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ));
                      },
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
                    Positioned(
                      bottom: 5, 
                      right: 5, 
                      child: Container(
                        height: 30, 
                        width: 90,
                        child: FloatingActionButton(
                          onPressed: () {
                            reset(); 
                            activityOption = getSelectedActivity(); 
                            _getLocation(inputDistance); 
                          },
                          child: Text('Regenerate'),
                        ),
                      )
                    )
                  ],
                ),
              ),
              behavior: HitTestBehavior.translucent,
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
                      'assets/icons/img_walking.svg',
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
                      'assets/icons/img_clock.svg',
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
                      'assets/icons/img_trees.svg',
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
                      'assets/icons/img_stairs.svg',
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
                      'assets/icons/img_arrow_up.svg',
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
                  ],
                ),
              ),
            ],
          ),
        ),
        if (saved) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: RemoveTrail(
              onRemove: (value) {
                setState(() {
                  saved = value;
                  widget.onSaveChanged(false);
                });
              },
            ),
          ),
        ] else ...[
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
        ]
      ])),
    );
  }
}

/// A StatefulWidget for saving a trail.
///
/// This widget provides a button for saving a trail. It triggers the [onSave]
/// callback function when pressed, passing a boolean value indicating whether
/// the trail is saved or not.
class SaveTrail extends StatefulWidget {
  final Function(bool) onSave;

  const SaveTrail({Key? key, required this.onSave}) : super(key: key);
  @override
  State<SaveTrail> createState() => _SaveTrailState();
}

/// The state for the SaveTrail widget.
///
/// Manages the state and UI for the SaveTrail widget, which provides a button
/// for saving a trail. When pressed, it triggers the [onSave] callback function
/// to indicate that the trail is saved.
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

/// A StatefulWidget for removing a trail.
///
/// This widget provides a button for removing a saved trail. It triggers the [onRemove]
/// callback function when pressed, passing a boolean value indicating whether
/// the trail should be removed or not.
class RemoveTrail extends StatefulWidget {
  final Function(bool) onRemove;

  const RemoveTrail({Key? key, required this.onRemove}) : super(key: key);

  @override
  State<RemoveTrail> createState() => _RemoveTrailState();
}

/// The state for the RemoveTrail widget.
///
/// Manages the state and UI for the RemoveTrail widget, which provides a button
/// for removing a saved trail. When pressed, it triggers the [onRemove] callback function
/// to indicate that the trail should be removed.
class _RemoveTrailState extends State<RemoveTrail> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget.onRemove(false);
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Remove Trail',
          style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }
}
