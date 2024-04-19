import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/pages/challenge_page.dart';
import 'package:trailquest/pages/profile_page.dart';
import 'package:trailquest/pages/start_page.dart';
import 'package:trailquest/pages/trail_page.dart';

void main() {
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
    const ProfilePage()
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
            icon: SvgPicture.asset('assets/images/img_home.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),),
            activeIcon: SvgPicture.asset('assets/images/img_home.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),),
            label: 'Start'),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/img_trails.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),),
            activeIcon: SvgPicture.asset('assets/images/img_trails.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Trails'),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/img_trophy.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),),
            activeIcon: SvgPicture.asset('assets/images/img_trophy.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Challanges'),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/images/img_profile.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.green.shade900, BlendMode.srcIn),),
            activeIcon: SvgPicture.asset('assets/images/img_profile.svg',
              width: 40,
              height: 40,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Profile')
          ],
        ),
      ),
    );
  }
}
