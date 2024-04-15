import 'package:flutter/material.dart';

class StartPage extends StatelessWidget{ 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(

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

        body: const Center(
          child: Text('Start!', 
            style: TextStyle(
              color: Colors.green, 
              fontSize: 30.0,
            )
          ), 
        ),
      ),
    );
  }
}