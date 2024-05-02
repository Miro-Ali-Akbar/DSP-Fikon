import 'package:flutter_config/flutter_config.dart';
import 'dart:async';

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

WebSocketChannel? channel;

void main() async {
  // https://pub.dev/packages/flutter_config
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();
  var googleMapsApiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  channel = WebSocketChannel.connect(Uri.parse("ws://trocader.duckdns.org:3000"));

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
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
