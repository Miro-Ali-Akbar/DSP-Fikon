import 'package:flutter_config/flutter_config.dart';
import 'dart:async';

import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
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
ValueNotifier<List<dynamic>> friendsList = ValueNotifier([
  ['{"name": "emma" , "score": 30, "recentChallenges": ["Checkpoint  score gained: 30"], "profilePic" : "url"}'
    
  ]
]);
ValueNotifier<List<String>> friendRequests =
    ValueNotifier(["emma", "meep", "ghhh", "fgg"]);
String feedBack = "";
var jsonString = '';
List<dynamic> leaderList = [];
String myUserName = "default_username888";


ValueNotifier<bool> canSendRequest = ValueNotifier(true);
ValueNotifier<bool> isSent = ValueNotifier(false);
ValueNotifier<bool> friendRequestSuccess = ValueNotifier<bool>(true);
ValueNotifier<bool> alreadyRequested = ValueNotifier(false);

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
        print(msgID);

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
            leaderList = temp;
            print(leaderList);
            break;

          case 'init':
            Map<String, dynamic> friend = data['friends'];
            friend.forEach((key, value) {
              friendsList.value.add(value);
            });
            Map<String, dynamic> reqs = data['requests'];
            reqs.forEach(
              (key, value) => friendRequests.value.add(value),
            );
            Map<String, dynamic> users = data['leaderBoard'];
            List<String> temp = [];
            users.forEach((key, value) {
              temp.add(array_to_string([value[0], value[1]]));
            });
            leaderList = temp;
            myUserName = data['username'];
            break;

          case 'outGoingRequest':
            
            if (data['error'] == 1) {
              
              friendRequestSuccess.value = true;
              canSendRequest.value = true;
              isSent.value = true;
            } else {
              int res = data['error'];
              friendRequestSuccess.value = false;
              canSendRequest.value = true;
             
            }
            break;
          case 'incomingRequest':
            friendRequests.value.add(data['name']);
            break;
          case 'newFriend':
            friendsList.value.add(data['newFriend']);

            break;
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

class Friend extends StatelessWidget {
  final String profilePic;
  final String name;

  final List<String> recentChallenges;
  final int score;

  const Friend(
      {super.key,
      required this.name,
      required this.profilePic,
      required this.recentChallenges,
      required this.score});
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
            Text(this.profilePic),
            Column(
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
        ));
  }
}

void accept(String name) {
  channel?.sink.add(
      '"msgID": "acceptRequest", "data": {"target": "$name", "sender": "$myUserName}');
  friendRequests.value.remove("$name");
} 

void reject(String name) {
  channel?.sink.add(
      '"msgID": "rejectRequest", "data": {"target": "$name", "sender": "$myUserName}');
  friendRequests.value.remove("$name");
}
