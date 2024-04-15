import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    return TextButton.icon(
      onPressed: () {
        Navigator.pop(context); 
      }, 

      icon: SvgPicture.asset('assets/images/arrow-sm-left-svgrepo-com (1).svg',
        width: 40,
        height: 40,
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)
      ),

      label: Text(''), 
    ); 
  }
}