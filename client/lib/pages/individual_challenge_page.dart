import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

class IndividualChallengePage extends StatefulWidget {
  final Challenge challenge;

  IndividualChallengePage({
    super.key,
    required this.challenge
  });

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