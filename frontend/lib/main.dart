import 'package:flutter/material.dart';
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
    StartPage(),
    TrailPage(),
    ChallengePage(), 
    ProfilePage()
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
          items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Start'),
          BottomNavigationBarItem(
            icon: Icon(Icons.earbuds_outlined), 
            label: 'Trails'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt), 
            label: 'Challanges'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profile')
          ],
        ),
      ),
    );
  }
}
