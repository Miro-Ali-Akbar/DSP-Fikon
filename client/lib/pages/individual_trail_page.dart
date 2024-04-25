import 'package:flutter/material.dart';

class IndividualTrailPage extends StatelessWidget{

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
            Center(
              child: Column(
                children: [
                  Text('Trail Page!!', 
                    style: TextStyle(
                      color: Colors.green, 
                      fontSize: 30.0,
                    )
                  ), 
                ],
              ),
            ),
          ]
        )  
      ),
    );
  }
}