import 'package:flutter/material.dart';
import 'package:trailquest/pages/challengePage.dart';
import 'package:trailquest/pages/profilePage.dart';
import 'package:trailquest/pages/startPage.dart';
import 'package:trailquest/pages/trailPage.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

WebSocketChannel? channel;

void main() {
  channel = WebSocketChannel.connect(Uri.parse("ws://localhost:3000"));
  runApp(const MainApp());
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
      home: Scaffold(
        body: screens[myIndex],

        appBar: AppBar(
          actions: const [],
          title: const Align(
            alignment: Alignment.centerRight,
            child: Text('TrailQuest', 
              style: TextStyle(
              color: Colors.black),
              ),
          ),
        ),

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
