
import 'package:flutter/material.dart';
import 'package:trailquest/pages/generate_trail_page.dart';

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
      onPressed: () {
        Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
          pageBuilder: (context, x, xx) => GenerateTrail(),
          transitionDuration: Duration.zero, 
          reverseTransitionDuration: Duration.zero));
      }, 

      style: TextButton.styleFrom(
        backgroundColor: Colors.green, 
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        )
      ),

      child: const Text('Generate new trail +', style: TextStyle(color: Colors.white, fontSize: 30)), 
    ); 
  }
}