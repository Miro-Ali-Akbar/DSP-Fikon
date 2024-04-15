import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget{ 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Profile!', 
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