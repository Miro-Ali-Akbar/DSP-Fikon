import 'package:flutter/material.dart';

class ChallengePage extends StatelessWidget{ 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Challenge!', 
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