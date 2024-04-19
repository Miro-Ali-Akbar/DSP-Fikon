import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
            Center(
              child: Column(
                children: [
                  Text('Generate new trail here!', 
                    style: TextStyle(
                      color: Colors.green, 
                      fontSize: 30.0,
                    )
                  ),
                  InfoPage(),
                  CreateNewTrail(), 
                ],
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

class CreateNewTrail extends StatelessWidget {
  const CreateNewTrail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null, 
      style: TextButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: const Text('Generate new trail +', style: TextStyle(color: Colors.white, fontSize: 30)),
    );
  }
}

class InfoPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('What activity do you want to do?'), 
        Text('How long do you want the trail to be?'),
        Text('Do you want the end point to be the same as the start point?'), 
        Text('Do you want to start from your current position?'),
        Text('What kind of enviornment do you want?'),
      ],
    );
  }
}