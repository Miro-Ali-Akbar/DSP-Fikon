import 'package:flutter_config/flutter_config.dart';
import 'dart:async';

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trailquest/pages/challenge_page.dart';
import 'package:trailquest/pages/profilepage/auth_gate.dart';
import 'package:trailquest/pages/start_page.dart';
import 'package:trailquest/pages/trail_page.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:convert';

WebSocketChannel? channel;
var jsonString = '';
List<String> dataList = [];

void Listen() {
  try {
    channel?.stream.listen((jsonString) {
      Map<String, dynamic> jsonDecoded = jsonDecode(jsonString);
      String msgID;
      if (jsonDecoded.isNotEmpty) {
        // Get the first key-value pair from the Map
        MapEntry<String, dynamic> firstEntry = jsonDecoded.entries.first;

        // Extract the value
        msgID = firstEntry.value;

        MapEntry<String, dynamic> secondEntry =
            jsonDecoded.entries.elementAt(1);
        dynamic data = secondEntry.value;

        switch (msgID) {
          case 'leaderboard':
            Map<String, dynamic> users = data;
            List<String> temp = [];
            users.forEach((key, value) {
              temp.add(array_to_string([value[0], value[1]]));
            });
            dataList = temp;
            print(dataList);
            break;
          case 'init':
            print(data);
            break;
        }
      }
    });
  } catch (e) {
    print(e);
  }
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

Future<dynamic> _requestPermissions() async {
  if (await Permission.location.request().isGranted) {
    print("Location services permission granted");
  } else {
    return Future.error("Location services permission were denied");
  }

  if (await Permission.activityRecognition.request().isGranted) {
    print("Activity recognition permission granted");
  } else {
    return Future.error("Activity recognition permission denied");
  }
}

void main() async {
  // https://pub.dev/packages/flutter_config
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();
  var googleMapsApiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  channel =
      WebSocketChannel.connect(Uri.parse("ws://trocader.duckdns.org:3000"));
  channel?.sink.add('{"msgID": "getLeaderboard"}');
  Listen();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

String array_to_string(List tuple) {
  return tuple[1].toString() + " " + tuple[0];
}

// Controllers for geofences
final activityStreamController = StreamController<Activity>();
final geofenceStreamController = StreamController<Geofence>();

// Settings for geofences
final geofenceService = GeofenceService.instance.setup(
    interval: 2000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: true,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

List<GeofenceRadius> geofenceRadiusList = [
  GeofenceRadius(id: "radius_25m", length: 25)
];

class _MainAppState extends State<MainApp> {
  int myIndex = 0;
  final screens = [
    const StartPage(),
    TrailPage(),
    ChallengePage(),
    AuthGate(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions().catchError(print);
  }

  @override
  Widget build(BuildContext context) {
    return WillStartForegroundTask(
        onWillStart: () async {
          return geofenceService.isRunningService;
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
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'InterRegular'),
          home: Scaffold(
            body: screens[myIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  myIndex = index;
                });
              },
              currentIndex: myIndex,
              backgroundColor: Colors.green.shade600,
              selectedItemColor: Colors.white,
              items: [
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icons/img_home.svg',
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                          Colors.green.shade900, BlendMode.srcIn),
                    ),
                    activeIcon: SvgPicture.asset(
                      'assets/icons/img_home.svg',
                      width: 40,
                      height: 40,
                      colorFilter:
                          ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    label: 'Start'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icons/img_trails.svg',
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                          Colors.green.shade900, BlendMode.srcIn),
                    ),
                    activeIcon: SvgPicture.asset('assets/icons/img_trails.svg',
                        width: 40,
                        height: 40,
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    label: 'Trails'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icons/img_trophy.svg',
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                          Colors.green.shade900, BlendMode.srcIn),
                    ),
                    activeIcon: SvgPicture.asset('assets/icons/img_trophy.svg',
                        width: 40,
                        height: 40,
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    label: 'Challanges'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icons/img_profile.svg',
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                          Colors.green.shade900, BlendMode.srcIn),
                    ),
                    activeIcon: SvgPicture.asset('assets/icons/img_profile.svg',
                        width: 40,
                        height: 40,
                        colorFilter:
                            ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    label: 'Profile')
              ],
            ),
          ),
        ));
  }
}
