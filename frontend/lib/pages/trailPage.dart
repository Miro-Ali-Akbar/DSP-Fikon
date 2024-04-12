import 'package:flutter/material.dart';

class TrailPage extends StatelessWidget{ 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Trail!', 
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