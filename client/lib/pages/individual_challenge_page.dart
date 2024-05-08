import 'dart:async';
import 'dart:convert';

import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trailquest/pages/challenge_page.dart';
import 'package:trailquest/widgets/challenge.dart';
import 'package:trailquest/widgets/back_button.dart';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

String googleMapsApiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

LatLng currentPosition = LatLng(0, 0);
bool isInArea = false;
int geofenceIndex = 0;
List<Marker> markerList = [];

Future<void> _getSetCurrentPosition() async {
  Position position = await Geolocator.getCurrentPosition();
  currentPosition = LatLng(position.latitude, position.longitude);
}

/// A blueprint for a page displaying information about a specific challenge and providing the means
/// to start and do the challenge.
class IndividualChallengePage extends StatefulWidget {
  Challenge challenge;

  IndividualChallengePage({required this.challenge});

  @override
  State<IndividualChallengePage> createState() =>
      _IndividualChallengeState(challenge: challenge);
}

class _IndividualChallengeState extends State<IndividualChallengePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  // Controllers for geofences
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  // Settings for geofences
  final _geofenceService = GeofenceService.instance.setup(
      interval: 2000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: true,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // Automatically called every time the status of a geofence is changed
  // Most game logic will be placed here
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);

    if (geofenceStatus.toString() == "GeofenceStatus.ENTER") {
      print("Entered area");
      setState(() {
        isInArea = true;
      });
      // TODO: Game-logic associated with each type of challenge
      // FIXME: If a challenge gets another name, update this function
      if (challenge.status == 1) {
        String geofenceId = geofence.toJson()['id'];
        print(geofenceId);

        switch (challenge.type) {
          case 'Orienteering':
            _geofenceService.removeGeofenceById(geofence.toJson()['id']);

            // TODO: Cleanup if possible
            setState(() {
              Marker marker = markerList
                  .firstWhere((marker) => marker.markerId.value == geofenceId);
              setState(() {
                markerList.remove(marker);
              });
            });
            setState(() {
              challenge.progress++;
              updateScore(challenge.points);
            });

            break;
          case 'Checkpoints':
            // TODO: Implement
            if (geofenceId == "loc_$geofenceIndex") {
              _geofenceService.removeGeofenceById(geofence.toJson()['id']);
              setState(() {
                Marker marker = markerList.firstWhere(
                    (marker) => marker.markerId.value == geofenceId);
                markerList.remove(marker);
              });
              setState(() {
                geofenceIndex++;
                challenge.progress++;
                updateScore(challenge.points);
              });
            } else {
              print("Wrong checkpoint!");
            }

            break;
          case 'Treasure hunt':
            // TODO: Implement
            break;
          default:
            throw Exception("Unknown activity-check in geofencestatus");
        }

        if (challenge.progress == challenge.complete) {
          challenge.status = 2;
        }
      }
    }
  }

  // Unused
  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
    currentPosition = LatLng(location.latitude, location.longitude);
  }

  // Unused
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
  }

  Challenge challenge;

  _IndividualChallengeState({required this.challenge});

  @override
  Widget build(BuildContext context) {
    String type = widget.challenge.type;

    return WillStartForegroundTask(
        onWillStart: () async {
          return _geofenceService.isRunningService;
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription:
              'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: const ForegroundTaskOptions(),
        // TODO: Change message?
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GoBackButton(),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(widget.challenge.name,
                        style: TextStyle(fontSize: 25)),
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image(
                          width: 400,
                          fit: BoxFit.contain,
                          image: AssetImage(widget.challenge.image),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.challenge.description,
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Instruction: $type',
                                  style: TextStyle(fontSize: 18),
                                ),
                                ChallengeInstruction(widget.challenge),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ProgressTracker(challenge))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ShowMap(context, challenge, _geofenceService, _controller)
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      if (widget.challenge.status == 0) {
                        widget.challenge.status = 1;
                        ChallengeMap(context, widget.challenge,
                            _geofenceService, _controller);
                      } else if (widget.challenge.status == 1) {
                        widget.challenge.status = 0;
                      }
                    });
                  },
                  style: StyleStartStopChallenge(widget.challenge),
                  child: TextStartStopChallenge(widget.challenge),
                ),
              ),
            ],
          ),
        ));
  }
}

/// Displays an instruction about the challenge type of the current challenge
///
/// [challenge] The current challenge
///
/// returns a Text with the instruction
Widget ChallengeInstruction(Challenge challenge) {
  String type = challenge.type;

  if (type == 'Checkpoints') {
    return Text(
        'In a checkpoint challenge you will receive a trail with a number of checkpoints you need to visit. You need to visit all of them to complete the challenge',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center);
  } else if (type == 'Treasure hunt') {
    return Text(
        "In a treasure hunt you need to visit a number of locations to complete the challenge. You will not know where these are located beforehand.\n\n When pressing 'start challenge' you will receive a trail leading to the first location. When you have reached that location, you will receive a trail leading to the next one and so on.",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center);
  } else if (type == 'Orienteering') {
    return Text(
      "In orienteering you will receive a number of control points to visit. How you get to these locations is up to you, but you must visit all control points to complete the challenge",
      style: TextStyle(fontSize: 16),
      textAlign: TextAlign.center,
    );
  } else {
    return Text(' ');
  }
}

Widget ProgressTracker(Challenge challenge) {
  String type = challenge.type;
  int progress = challenge.progress;
  int complete = challenge.complete;
  int currentPoints = progress * challenge.points;
  int allPoints = complete * challenge.points;

  if (type == 'Checkpoints') {
    return Container(
      height: 100,
      color: const Color.fromARGB(255, 89, 164, 224),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$progress/$complete checkpoints',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$currentPoints points gained of $allPoints total',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  } else if (type == 'Treasure hunt') {
    return Container(
      height: 100,
      color: const Color.fromARGB(255, 250, 159, 74),
      child: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$progress/$complete locations visited',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$currentPoints points gained of $allPoints total',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  } else if (type == 'Orienteering') {
    return Container(
      height: 100,
      color: const Color.fromARGB(255, 137, 70, 196),
      child: Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$progress/$complete control points',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '$currentPoints points gained of $allPoints total',
              style: TextStyle(
                fontSize: 25,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  } else {
    return Container();
  }
}

/// Picks the style of the button for starting and stopping challenges based on the status of
/// the current challenge
///
/// [challenge] The current challenge
///
/// Returns a ButtonStyle with different background colors depending on if the challenge is
/// 'not started', 'ongoing' or 'done'
ButtonStyle StyleStartStopChallenge(Challenge challenge) {
  if (challenge.status == 0) {
    return TextButton.styleFrom(
      backgroundColor: Colors.green.shade600,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  } else if (challenge.status == 1) {
    return TextButton.styleFrom(
      backgroundColor: Colors.green.shade900,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  } else {
    return TextButton.styleFrom(
      backgroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}

/// Picks which text should be displayed on the button for starting and stopping challenges based
/// on the status of the current challenge
///
/// [challenge] The current challenge
///
/// Returns a text with either start, stop or finished challenge depending on if the status of the
/// current challenge is 'not started', 'ongoing' or 'done'
Text TextStartStopChallenge(Challenge challenge) {
  if (challenge.status == 0) {
    return Text('Start challenge',
        style: TextStyle(color: Colors.white, fontSize: 25));
  } else if (challenge.status == 1) {
    return Text('Stop challenge?',
        style: TextStyle(color: Colors.white, fontSize: 25));
  } else {
    return Text('Finished challenge!',
        style: TextStyle(color: Colors.white, fontSize: 25));
  }
}

/// Overlaying map housing the actual challenge
///
/// Depending on the type of game a route is generated or not. Likewise
/// the player can see their position
ChallengeMap(BuildContext context, Challenge challenge, final geofenceService,
    Completer<GoogleMapController> _controller) async {
  await _getSetCurrentPosition();
  List<LatLng> dataList = await _getCloseData(5000, challenge);
  List<Geofence> geofenceList =
      _getGefenceList(dataList, [GeofenceRadius(id: "radius_25m", length: 25)]);
  markerList = _getMarkerList(dataList);
  List<Polyline> polylines = await _getPolylines(challenge, dataList);

  _addGeofences(geofenceList, geofenceService);

  bool canSeePosition = _checkLocationVisibility(challenge);

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(3),
          content: Container(
            height: 600,
            width: 800,
            child: GoogleMap(
              myLocationEnabled: canSeePosition,
              polylines: Set<Polyline>.of(polylines),
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentPosition.latitude, currentPosition.longitude),
                  zoom: 12),
              markers: Set<Marker>.of(markerList),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        );
      });
}

Widget ShowMap(BuildContext context, Challenge challenge, final geofenceService,
    Completer<GoogleMapController> _controller) {
  if(challenge.status == 1) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: TextButton.icon(
        onPressed: () {
          ChallengeMap(context, challenge,
                            geofenceService, _controller);
        },
        label: Text('Show map', style: TextStyle(
          color: Colors.white,
          fontSize: 25
        ),),
        icon: SvgPicture.asset('assets/icons/img_map.svg', height: 35,),
        style: TextButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          minimumSize: Size.fromHeight(70)
        ),
      ),
    );
  } else {
    return Container();
  }
}

/// Returns whether the location of the user should be visible on
/// the map or not
bool _checkLocationVisibility(Challenge challenge) {
  print("Visibility: ${challenge.type}");
  switch (challenge.type) {
    case 'Checkpoints':
      print("Visible");
      return true;
    case 'Orienteering':
      print("Not visible");
      return false;
    case 'Treasure hunt':
      print("Visible");
      return true;
    default:
      print("Default = true");
      return true;
  }
}

/// Returns wheter a polyline should be visible on the map or not
bool _checkPolylineVisibility(Challenge challenge) {
  print("Visibility: ${challenge.type}");
  switch (challenge.type) {
    case 'Checkpoints':
      print("Visible");
      return true;
    case 'Orienteering':
      print("Not visible");
      return false;
    case 'Treasure hunt':
      // TODO: Change to return int (or string) for more stages
      //       i.e. special for treasure hunt
      print("Visible");
      return false;
    default:
      print("Default = true");
      return true;
  }
}

/// Returns a list of all polylines to be overlayed on the map if
/// a polyline should be visible. The polyline generated is a route
/// from the coordinates in [points]
///
/// [challenge] is used for checking the visibility of a polyline.
/// If not visible a polyline will not be generated. Instead an
/// empty list is returned. Overlaying this will have the same
/// effect as not overlaying enything
Future<List<Polyline>> _getPolylines(
    Challenge challenge, List<LatLng> points) async {
  List<Polyline> polylines = [];
  if (_checkPolylineVisibility(challenge)) {
    PolylinePoints polylinePoints = PolylinePoints();

    points.insert(0, currentPosition);
    PointLatLng origin =
        PointLatLng(points.first.latitude, points.first.longitude);
    PointLatLng destination =
        PointLatLng(points.last.latitude, points.last.longitude);

    List<PolylineWayPoint> polylineWayPoints = [];
    for (var i = 0; i < points.length; i++) {
      PolylineWayPoint polylineWayPoint = PolylineWayPoint(
          location: "${points[i].latitude},${points[i].longitude}");
      polylineWayPoints.add(polylineWayPoint);
    }

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapsApiKey, origin, destination,
        travelMode: TravelMode.walking, wayPoints: polylineWayPoints);

    if (result.points.isNotEmpty) {
      List<LatLng> resultLatLngs = [];
      result.points.forEach((PointLatLng point) {
        resultLatLngs.add(LatLng(point.latitude, point.longitude));
      });
      polylines.add(Polyline(
          polylineId: PolylineId('polyline'),
          color: Colors.red,
          points: resultLatLngs));
    }
  }
  return polylines;
}

/// Returns a list of all statues close to the user
///
/// [surroundingMeters] how far around the user the data should be collected
/// [challenge] challenge to get data from from. Uses [challenge.dataType]
Future<List<LatLng>> _getCloseData(
    int surroundingMeters, Challenge challenge) async {
  List<LatLng> nodes = [];

  var url;
  switch (challenge.dataType) {
    case 'statues':
      url =
          '''https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];
          (
          node[artwork_type=statue](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[artwork=statue](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[memorial=statue](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[man_made=statue](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          );
          out geom;''';
      break;
    case 'rocks':
      url =
          '''https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];
          (
          node[natural=stone](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[natural=rock](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[memorial=stone](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[historic=stone](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          );
          out geom;''';
    case 'demo':
      return [LatLng(59.839227286548116, 17.647351395137616)];
    default:
      throw Exception("Retrieval of unkonwn data from Overpass API");
  }

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    List<dynamic> elements = decoded['elements'];

    for (var element in elements) {
      nodes.add(LatLng(element['lat'], element['lon']));
    }
  }

  return nodes;
}

/// Returns a list of all geogfences generated from [positions]
///
/// [radiusList] list of radiuses for each geofence
List<Geofence> _getGefenceList(
    List<LatLng> positions, List<GeofenceRadius> radiusList) {
  List<Geofence> geofences = [];

  for (var i = 0; i < positions.length; i++) {
    Geofence geofence = Geofence(
        id: 'loc_$i',
        latitude: positions[i].latitude,
        longitude: positions[i].longitude,
        radius: radiusList);
    geofences.add(geofence);
  }

  return geofences;
}

/// Returns a list of markers generated from [positions]
List<Marker> _getMarkerList(List<LatLng> positions) {
  List<Marker> markers = [];

  for (var i = 0; i < positions.length; i++) {
    Marker marker =
        Marker(markerId: MarkerId('loc_$i'), position: positions[i]);
    markers.add(marker);
  }

  return markers;
}

/// Adds [geofences] to [geofenceService]
void _addGeofences(List<Geofence> geofences, GeofenceService geofenceService) {
  for (var i = 0; i < geofences.length; i++) {
    geofenceService.addGeofence(geofences[i]);
  }
}
