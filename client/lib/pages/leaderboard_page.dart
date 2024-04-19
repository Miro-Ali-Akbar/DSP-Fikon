import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:trailquest/challenges_list.dart';
// import 'package:trailquest/widgets/challenge_cards.dart';


class Leaderboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Leaderboard',
            style: TextStyle(
              color: Colors.green, 
              fontSize: 30.0,
            )
          )
        ),
        body: Column(children: [
          
        ],
        )
      )
    );
  }
}