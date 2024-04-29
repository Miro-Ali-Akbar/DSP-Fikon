import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge.dart';

class IndividualChallengePage extends StatefulWidget {
  Challenge? challenge;

  IndividualChallengePage(Challenge c) {
    this.challenge = c;
  }

  @override
  State<IndividualChallengePage> createState() => _ChallengeState();
}

class _ChallengeState extends State<IndividualChallengePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Text('individual challenge page')
    );
  }
}