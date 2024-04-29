import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trailquest/widgets/back_button.dart';
import 'package:trailquest/widgets/challenge.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

class IndividualChallengePage extends StatefulWidget {
  Challenge challenge;

  IndividualChallengePage({
    required this.challenge
  });

  @override
  State<IndividualChallengePage> createState() => _IndividualChallengeState(challenge: challenge);
}

class _IndividualChallengeState extends State<IndividualChallengePage> {
  Challenge challenge;
  

  _IndividualChallengeState({required this.challenge});

  @override
  Widget build(BuildContext context) {
    String type = challenge.type;
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: Column( 
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
            ),
            Row(
              children: [
                GoBackButton(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('${widget.challenge.name}', 
                    style: TextStyle(fontSize: 27)),
                ),
              ],
            ),
            Container(
              width: 400,
              child: Image(
                fit: BoxFit.contain,
                image: AssetImage(widget.challenge.image)
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 10),
                  width: 370,
                  child: Text(
                    widget.challenge.description,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(top: 20)),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black)
                  ),
                  width: 370,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children:[
                        Text('Instruction: $type',
                          style: TextStyle(
                            fontSize: 18
                          ),
                        ),
                        ChallengeInstruction(widget.challenge)
                      ]
                    )
                  )
                )
              ],
            )
          ]
        )
      ),
    );
  }
}

Widget ChallengeInstruction(Challenge challenge){
  String type = challenge.type;

  if(type == 'Checkpoints'){
    return Text('In a checkpoint challenge you will receive a trail with a number of checkpoints you need to visit. You need to visit all of them to complete the challenge',
      style: TextStyle(
        fontSize: 16
      ),
      textAlign: TextAlign.center
    );
  } else if(type == 'Treasure hunt') {
    return Text("In a treasure hunt you need to visit a number of locations to complete the challenge. You will not know where these are located beforehand.\n\n When pressing 'start challenge' you will receive a trail leading to the first location. When you have reached that location, you will receive a trail leading to the next one and so on.",
      style: TextStyle(
        fontSize: 16
      ),
      textAlign: TextAlign.center
    );
  } else if(type == 'Orienteering') {
    return Text("In orienteering you will receive a number of control points to visit. How you get to these locations is up to you, but you must visit all control points to complete the challenge",
      style: TextStyle(
        fontSize: 16
      ),
      textAlign: TextAlign.center
    ,);
  } else {
    return Text(' ');
  }
}