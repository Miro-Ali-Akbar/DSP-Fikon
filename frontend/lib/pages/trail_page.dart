import 'package:flutter/material.dart';

class TrailPage extends StatelessWidget{ 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(

        body: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
              CreateNewTrail(),
              const SizedBox(height: 150),
              const Text('Trail!', 
              style: TextStyle(
                color: Colors.green, 
                fontSize: 30.0,
              )
            ),] 
          ),
        ),
      ),
    );
  }
}

class CreateNewTrail extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null, 
      
      child: Text('Create new trail +', style: TextStyle(color: Colors.white, fontSize: 30)), 
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
      ),
    ); 
  }
}