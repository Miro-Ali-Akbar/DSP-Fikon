import 'dart:async';
import 'dart:io';
// import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geofence_service/geofence_service.dart' hide LocationPermission;

WebSocketChannel? channel;

void main() {
  channel = WebSocketChannel.connect(Uri.parse("ws://192.168.46.200:3000"));
  runApp(const MyApp());
}

void _sendMessage(String message) {
  print(message);

  try {
    channel?.sink.add(message);
    channel?.stream.listen((message) {
      print(message);
      channel?.sink.close();
    });
  } catch (e) {
    print(e);
  }
}

Future<dynamic> _requestLocationPermission() async {
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
}

Future<Position> _determinePosition() async {
  _requestLocationPermission().catchError(print);

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
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
  final Completer<GoogleMapController> _controller = Completer();
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();
  var position;
  int activeIndex = 0;
  bool isInArea = false;

  // Create a [GeofenceService] instance and set options.
  final _geofenceService = GeofenceService.instance.setup(
      interval: 2000,
      accuracy: 10,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: true,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  List<LatLng> points = [
    const LatLng(59.85747242495416, 17.625860077218743),
    const LatLng(59.858159646672945, 17.627228655854065),
    const LatLng(59.858519279278624, 17.629492615895174),
    const LatLng(59.85941849274688, 17.625949593271745),
  ];

  MapsRoutes route = MapsRoutes();
  DistanceCalculator distanceCalculator = DistanceCalculator();
  String googleApiKey = 'API-KEY';
  String totalDistance = 'No route';

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
  }

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);

    if (geofenceStatus.toString() == "GeofenceStatus.ENTER" &&
        geofence.toJson().toString().contains(RegExp('loc_$activeIndex'))) {
      print("Entered area");
      setState(() {
        isInArea = true;
      });
    } else if (geofenceStatus.toString() == "GeofenceStatus.EXIT") {
      print("Left area");

      if (activeIndex == 0) {
        print("Entered if");
        _geofenceService.removeGeofenceById('loc_${points.length - 1}');
      } else {
        _geofenceService.removeGeofenceById('loc_${activeIndex - 1}');
      }

      setState(() {
        isInArea = false;
      });
    }
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
    _requestLocationPermission().catchError(print);
    Geolocator.getPositionStream().listen((position) {
      centerScreen(position);
      _sendMessage("$position");
    });

    () async { while (true) {
      _sendMessage(position);
      sleep(Duration(seconds: 5));
    }};
    
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
    _geofenceService.addGeofence(Geofence(
        id: "loc_$activeIndex",
        latitude: points[activeIndex].latitude,
        longitude: points[activeIndex].longitude,
        radius: [GeofenceRadius(id: "radius_10m", length: 10)]));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: WillStartForegroundTask(
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
          notificationTitle: 'Geofence Service is running',
          notificationText: 'Tap to return to the app',
          child: Scaffold(
            appBar: AppBar(
              title: const Text('TrailQuest'),
              elevation: 2,
            ),
            body: Stack(
              children: [
                Align(
                    alignment: Alignment.center,
                    child: StreamBuilder<Position>(
                      stream: Geolocator.getPositionStream(),
                      builder: (context, snapshot) {
                        // FIXME: Must reload app upon confirming permissions
                        if (snapshot.hasData) {
                          position = snapshot.data;
                          return GoogleMap(
                            zoomControlsEnabled: false,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: false,
                            polylines: route.routes,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  position!.latitude, position.longitude),
                              zoom: 15.0,
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: {
                              Marker(
                                  markerId: MarkerId("hello"),
                                  position: LatLng(points[activeIndex].latitude,
                                      points[activeIndex].longitude))
                            },
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(totalDistance,
                              style: const TextStyle(fontSize: 25.0)),
                        )),
                  ),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (isInArea) {
                  if (activeIndex < points.length - 1) {
                    await route.drawRoute(
                        [points[activeIndex], points[activeIndex + 1]],
                        'Test routes',
                        const Color.fromRGBO(130, 78, 210, 1.0),
                        googleApiKey,
                        travelMode: TravelModes.walking);
                    setState(() {
                      totalDistance = distanceCalculator.calculateRouteDistance(
                          [points[activeIndex], points[activeIndex + 1]],
                          decimals: 1);
                      activeIndex++;
                      isInArea = false;
                      _geofenceService.addGeofence(Geofence(
                        id: "loc_$activeIndex",
                        latitude: points[activeIndex].latitude,
                        longitude: points[activeIndex].longitude,
                        radius: [
                          GeofenceRadius(id: 'radius_10m', length: 10),
                        ],
                      ));
                    });
                  } else {
                    print(
                        "End of points reached\nReset back to original point");
                    await route.drawRoute(
                        [points[activeIndex], points[0]],
                        'Test routes',
                        const Color.fromRGBO(130, 78, 210, 1.0),
                        googleApiKey,
                        travelMode: TravelModes.walking);
                    setState(() {
                      totalDistance = distanceCalculator.calculateRouteDistance(
                          [points[activeIndex], points[0]],
                          decimals: 1);
                      activeIndex = 0;
                      isInArea = false;
                      _geofenceService.addGeofence(Geofence(
                        id: "loc_$activeIndex",
                        latitude: points[activeIndex].latitude,
                        longitude: points[activeIndex].longitude,
                        radius: [
                          GeofenceRadius(id: 'radius_10m', length: 10),
                        ],
                      ));
                    });
                  }
                } else {
                  print("Not in area");
                }
                // _determinePosition().then((value) {
                //   mapController.animateCamera(CameraUpdate.newLatLngZoom(
                //       LatLng(value.latitude, value.longitude), 14));
                //   // _sendMessage("$value");
                // });
                // _sendMessage("$position");
              },
            ),
          )),
    );
  }
}
