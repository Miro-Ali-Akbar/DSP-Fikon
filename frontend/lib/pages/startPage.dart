import 'package:flutter/material.dart';

class StartPage extends StatelessWidget{ 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
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