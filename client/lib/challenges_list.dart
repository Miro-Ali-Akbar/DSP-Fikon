import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

List<ChallengeCard> challenges = <ChallengeCard>[
  ChallengeCard(
    name: '10 statues in Uppsala', 
    type: 'Checkpoints', 
    description: Text('Find these 10 statues'), 
    //timeLimit: true,
    status: 0,
  ),
  ChallengeCard(
    name: 'Questions about birds', 
    type: 'Quiz', 
    description: Text('Answer questions about birds'), 
    //timeLimit: true,
    status: 2
  ),
  ChallengeCard(
    name: 'Cool large rocks', 
    type: 'Checkpoints', 
    description: Text('Visit cool large rocks in Uppsala'), 
    //timeLimit: false,
    status: 1,
  ),
  ChallengeCard(
    name: 'Orienteering in Luthagen', 
    type: 'Orienteering', 
    description: Text('Gather control points in Luthagen'), 
    //timeLimit: false,
    status: 1,
  ),
  ChallengeCard(
    name: 'Questions about plants', 
    type: 'Quiz', 
    description: Text('Answer questions about plants'), 
    //timeLimit: true,
    status: 2,
  ),
  ChallengeCard(
    name: 'Important buildings', 
    type: 'Quiz', 
    description: Text('Answer questions about importnat buildings'), 
    //timeLimit: false,
    status: 0
  ),
];