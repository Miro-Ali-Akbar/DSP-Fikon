import 'package:flutter_config/flutter_config.dart';
import 'dart:async';

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
List<dynamic> dataList = [];

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
            //channel?.sink.add(
            //    '{"msgID": "initRes", "data": { "username": "uName", "friendRequests": [], "friendlist": ["hitsu"], "online": true } }');

            print(data);
            break;
          case 'routes':
            //TODO: TEMP
            String trailName = data['trailName'];
            double totalDistance = data['totalDistance'];
            double totalTime = data['totalTime'];
            String statusEnvironment = data['statusEnvironment'];
            bool avoidStairs = data['avoidStairs'];
            double hilliness = data['hilliness'];

            List<dynamic> coordinatesJson = data['coordinates'];
            List<LatLng> coordinates = coordinatesJson
                .map((coord) => LatLng(coord['latitude'], coord['longitude']))
                .toList();
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

class _MainAppState extends State<MainApp> {
  int myIndex = 0;
  final screens = [
    const StartPage(),
    TrailPage(),
    ChallengePage(),
    AuthGate(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  colorFilter:
                      ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icons/img_home.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                label: 'Start'),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/img_trails.svg',
                  width: 40,
                  height: 40,
                  colorFilter:
                      ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),
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
                  colorFilter:
                      ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),
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
                  colorFilter:
                      ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),
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
    );
  }
}
