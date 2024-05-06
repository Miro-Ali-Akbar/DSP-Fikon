import 'dart:async';
import 'dart:convert';

import 'package:trailquest/widgets/challenge.dart';
import 'package:trailquest/widgets/back_button.dart';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

LatLng currentPosition = LatLng(0, 0);
bool isInArea = false;
List<Marker> markerList = [];

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
      accuracy: 10,
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
        switch (challenge.name) {
          case '10 statues in Uppsala':
            challenge.progress++;
            String geofenceId = geofence.toJson()['id'];
            print(geofenceId);
            // _geofenceService.removeGeofenceById(geofence.toJson()['id']);

            // setState(() {});
            Marker marker = markerList
                .firstWhere((marker) => marker.markerId.value == geofenceId);
              markerList.remove(marker);
            setState(() {
            });
            setState(() {});
            print(markerList);
            break;
          case 'Birds':
            // TODO: Implement
            break;
          case 'Cool large rocks':
            // TODO: Implement
            break;
          case 'Orienteering in Luthagen':
            // TODO: Implement
            break;
          case 'Pretty flowers':
            // TODO: Implement
            break;
          case 'Important buildings':
            // TODO: Implement
            break;
          default:
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

  if (type == 'Checkpoints') {
    return Container(
      height: 80,
      color: const Color.fromARGB(255, 89, 164, 224),
      child: Center(
        child: Text(
          '$progress/$complete checkpoints',
          style: TextStyle(fontSize: 25, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  } else if (type == 'Treasure hunt') {
    return Container(
      height: 80,
      color: const Color.fromARGB(255, 250, 159, 74),
      child: Center(
        child: Text(
          '$progress/$complete locations visited',
          style: TextStyle(fontSize: 25, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  } else if (type == 'Orienteering') {
    return Container(
      height: 80,
      color: const Color.fromARGB(255, 137, 70, 196),
      child: Center(
        child: Text(
          '$progress/$complete control points',
          style: TextStyle(fontSize: 25, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  } else {
    return Container();
  }
}

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

ChallengeMap(BuildContext context, Challenge challenge, final geofenceService,
    Completer<GoogleMapController> _controller) async {
  List<LatLng> dataList = await _getCloseData(5000, 'statues');
  List<Geofence> geofenceList =
      _getGefenceList(dataList, [GeofenceRadius(id: "radius_20m", length: 20)]);
  markerList = _getMarkerList(dataList);

  _addGeofences(geofenceList, geofenceService);

  bool canSeePosition = _checkLocationVisibility(challenge);

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            child: GoogleMap(
              myLocationEnabled: canSeePosition,
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
      print("Visible");
      // throw Exception("Unknown challenge type");
      return true;
  }
}

/// Returns a list of all statues close to the user
Future<List<LatLng>> _getCloseData(
    int surroundingMeters, String typeOfChallenge) async {
  List<LatLng> nodes = [];

  var url;
  switch (typeOfChallenge) {
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
    case 'stones':
      url =
          '''https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];
          (
          node[natural=stone](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[natural=rock](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[memorial=stone](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          node[historic=stone](around: $surroundingMeters, ${currentPosition.latitude}, ${currentPosition.longitude});
          );
          out geom;''';
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

List<Marker> _getMarkerList(List<LatLng> positions) {
  List<Marker> markers = [];

  for (var i = 0; i < positions.length; i++) {
    Marker marker =
        Marker(markerId: MarkerId('loc_$i'), position: positions[i]);
    markers.add(marker);
  }

  return markers;
}

void _addGeofences(List<Geofence> geofences, final geofenceService) {
  for (var i = 0; i < geofences.length; i++) {
    geofenceService.addGeofence(geofences[i]);
  }
}
