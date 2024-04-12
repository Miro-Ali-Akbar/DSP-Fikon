import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //body: Center(
        //  child: Text('Hello World!', 
        //    style: TextStyle(
        //      color: Colors.green, 
        //      fontSize: 30.0,
        //    )
        //  ), 
        //),

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
