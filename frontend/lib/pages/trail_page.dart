import 'package:flutter/material.dart';

class TrailPage extends StatelessWidget{
  const TrailPage({super.key});
 

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(

        body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              CreateNewTrail(),
              SizedBox(height: 150),
              Text('Trail!', 
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
  const CreateNewTrail({super.key});


  @override 
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null, 
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
      ), 
      
      child: const Text('Create new trail +', style: TextStyle(color: Colors.white, fontSize: 30)),
    ); 
  }
}