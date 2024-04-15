import 'package:flutter/material.dart';

class GenerateTrail extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: Column( 
          children: [
            Row(
              children: [
                BackButton().build(context),
              ],
            ), 
            const Center(
              child: Text('Generate new trail here!', 
                style: TextStyle(
                  color: Colors.green, 
                  fontSize: 30.0,
                )
              ), 
            ),
          ]
        )  
      ),
    );
  }
}

class BackButton extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context); 
      }, 

      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
      ),

      child: const Text('<--', style: TextStyle(color: Colors.black, fontSize: 30)), 
    ); 
  }
}