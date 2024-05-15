import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_config/flutter_config.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:trailquest/firebase_options.dart';
import 'package:trailquest/pages/challenge_page.dart';
import 'package:trailquest/pages/profilepage/auth_gate.dart';
import 'package:trailquest/pages/start_page.dart';
import 'package:trailquest/pages/trail_page.dart';

WebSocketChannel? channel;
ValueNotifier<List<dynamic>> friendsList = ValueNotifier([
  {"username": "emma", "score": 30},
  {"username": "eee", "score": 90}
]);
ValueNotifier<List<dynamic>> friendRequests =
    ValueNotifier(["emma", "meep", "ghhh", "fgg"]);
String feedBack = "";
var jsonString = '';

List<dynamic> leaderList = [];
ValueNotifier<String> myUserName = ValueNotifier("...");
ValueNotifier<bool> isNewUser = ValueNotifier(false);
ValueNotifier<bool> canSendRequest = ValueNotifier(true);
ValueNotifier<bool> isSent = ValueNotifier(false);
ValueNotifier<bool> friendRequestSuccess = ValueNotifier<bool>(true);
ValueNotifier<bool> alreadyRequested = ValueNotifier(false);
ValueNotifier<String> failMessage = ValueNotifier("");

/**
 * Listens for data sent from the server via the websocket
 * parses the message and updates values
 */

List<dynamic> userRoutes = [];
List<dynamic> friendsRoutes = [];
List<String> dataList = [];

void Listen() {
  try {
    channel?.stream.listen((jsonString) {
      Map<String, dynamic> jsonDecoded = jsonDecode(jsonString);
      String msgID;
      if (jsonDecoded.isNotEmpty) {
        // Get the first key-value pair from the Map
        MapEntry<String, dynamic> firstEntry = jsonDecoded.entries.first;

        // Extract the value of the message ID for the switch case
        msgID = firstEntry.value;

        //extracts the data

        MapEntry<String, dynamic> secondEntry =
            jsonDecoded.entries.elementAt(1);
        dynamic data = secondEntry.value;

        switch (msgID) {
          case 'initUser':
            if (data['changedUsername']) {
              if (data['friendlist'] != null) {
                friendsList.value = data['friendlist'];
              }
              if (data['friendRequests'] != null) {
                friendRequests.value = data['friendRequests'];
              }

              if (data['username'] != null) {
                myUserName.value = data['username'];
              }

              if (data['changedUsername'] != null) {
                isNewUser.value = !data['changedUsername'];
              }
            } else {
              if (data['changedUsername'] != null) {
                isNewUser.value = !data['changedUsername'];
              }
            }
            break;

          case 'outGoingRequest':
            if (data['error'] == 1) {
              friendRequestSuccess.value = true;
              canSendRequest.value = true;
              isSent.value = true;
            } else if (data['error'] == 0) {
              int res = data['error'];
              friendRequestSuccess.value = false;
              canSendRequest.value = true;
            } else {
              alreadyRequested.value = true;
              friendRequestSuccess.value = false;
              canSendRequest.value = true;
            }
            break;
          case 'incomingRequest':
            if (data['sender'] != null) {
              friendRequests.value = List.from(friendRequests.value)
                ..add(data['sender']);
            }
            break;
          case 'newFriend':
            if (data != null) {
              friendsList.value = List.from(friendsList.value)..add(data);
            }
            break;
          case 'usernameFail':
            failMessage.value = "User name is already taken, please try again";
            break;
          case 'usernameSuccess':
            isNewUser.value = false;
            isNewUser.notifyListeners();
            break;
          case 'leaderboard':
            Map<String, dynamic> users = data;
            List<String> temp = [];
            users.forEach((key, value) {
              temp.add(array_to_string([value[0], value[1]]));
            });
            dataList = temp;
            print(dataList);
            break;
          case 'initTrails':
            Map<String, dynamic> routes = data;

            List<dynamic> userTrailsData = routes['userTrails'];
            List<dynamic> friendTrailsData = routes['friendTrails'];

            if (!userTrailsData.isEmpty) {
              for (var i = 0; i < userTrailsData.length; i++) {
                Map<String, dynamic> trailData = userTrailsData[i];
                userRoutes.add({
                  'trailName': trailData['trailName'],
                  'totalDistance': trailData['totalDistance'],
                  'totalTime': trailData['totalTime'],
                  'statusEnvironment': trailData['statusEnvironment'],
                  'avoidStairs': trailData['avoidStairs'],
                  'hilliness': trailData['hilliness'],
                  'coordinates': trailData['coordinates']
                });
              }
            }

            if (!friendTrailsData.isEmpty) {
              for (var i = 0; i < friendTrailsData.length; i++) {
                Map<String, dynamic> trailData = friendTrailsData[i];
                friendsRoutes.add({
                  'trailName': trailData['trailName'],
                  'totalDistance': trailData['totalDistance'],
                  'totalTime': trailData['totalTime'],
                  'statusEnvironment': trailData['statusEnvironment'],
                  'avoidStairs': trailData['avoidStairs'],
                  'hilliness': trailData['hilliness'],
                  'coordinates': trailData['coordinates']
                });
              }
            }

            break;
          case 'returnRoute':
            Map<String, dynamic> trailData = data;
            userRoutes.add({
              'trailName': trailData['trailName'],
              'totalDistance': trailData['totalDistance'],
              'totalTime': trailData['totalTime'],
              'statusEnvironment': trailData['statusEnvironment'],
              'avoidStairs': trailData['avoidStairs'],
              'hilliness': trailData['hilliness'],
              'coordinates': trailData['coordinates']
            });
          default:
        }
      }
    });
  } catch (e) {
    print(e);
  }
}

void main() async {
  // https://pub.dev/packages/flutter_config
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  String ip = FlutterConfig.get('IP');
  String port = FlutterConfig.get('PORT');

  channel = WebSocketChannel.connect(Uri.parse("ws://$ip:$port"));
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

/**
 * Friend widget only displays scores of each friend
 */
class Friend extends StatelessWidget {
  final String name;

  final int score;

  const Friend({super.key, required this.name, required this.score});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(20),
        height: 120.0,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 3,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          color: Color.fromARGB(255, 252, 253, 252),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(this.name),
                Text("Score: " + this.score.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * Friend request widget
 */
class Request extends StatelessWidget {
  final String name;
  Request({required this.name});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 1,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color.fromARGB(216, 208, 247, 203),
              Color.fromARGB(73, 199, 245, 193)
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: const Color.fromARGB(26, 0, 0, 0),
          )),
      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: Row(
        children: [
          Expanded(child: Text(this.name)),
          IconButton(
              onPressed: () => accept(this.name), icon: Icon(Icons.check)),
          IconButton(
            onPressed: () => reject(this.name),
            icon: Icon(Icons.close),
          )
        ],
      ),
    );
  }
}

/**
 * accepts friendrequests by sending an accept message to the server and updating the UI
 * takes the name of the sender of the request  as argument
 */
void accept(String name) {
  print(name);
  channel?.sink.add(
      '{"msgID": "acceptRequest", "data": {"target": "$name", "sender": "${myUserName.value}"}}');
  friendRequests.value = List.from(friendRequests.value)..remove(name);
}

/**
 * rejects friendrequests by sending an accept message to the server and updating the UI
 * takes the name of the sender of the request as argument
 */
void reject(String name) {
  print(name);
  channel?.sink.add(
      '{"msgID": "rejectRequest", "data": {"target": "$name", "sender": "${myUserName.value}"}}');

  friendRequests.value = List.from(friendRequests.value)..remove(name);
}
