import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

const List<ChallengeCard> challenges = <ChallengeCard>[
  ChallengeCard(
    name: '10 statues in Uppsala', 
    type: 'Checkpoints', 
    description: Text('Find these 10 statues'), 
    timeLimit: false
  ),
  ChallengeCard(
    name: 'Questions about birds', 
    type: 'Quiz', 
    description: Text('Answer questions about birds'), 
    timeLimit: true
  ),
  ChallengeCard(
    name: 'Cool large rocks', 
    type: 'Checkpoints', 
    description: Text('Visit cool large rocks in Uppsala'), 
    timeLimit: true
  ),
  ChallengeCard(
    name: 'Orienteering in Luthagen', 
    type: 'Orienteering', 
    description: Text('Gather control points in Luthagen'), 
    timeLimit: true
  ),
  ChallengeCard(
    name: 'Questions about plants', 
    type: 'Quiz', 
    description: Text('Answer questions about plants'), 
    timeLimit: true
  ),
  ChallengeCard(
    name: 'Important buildings', 
    type: 'Quiz', 
    description: Text('Answer questions about importnat b'), 
    timeLimit: true
  ),
];