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
                      fontSize: 17,
                    ),
                  ),
                )
              ],
            )
          ]
        )
      ),
    );
  }
}