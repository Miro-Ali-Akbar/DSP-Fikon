import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

List<Challenge> challenges = <Challenge>[
  Challenge(
    name: '10 statues in Uppsala', 
    type: 'Checkpoints', 
    description: Text('Find these 10 statues'), 
    status: 0,
  ),
  Challenge(
    name: 'Questions about birds', 
    type: 'Quiz', 
    description: Text('Answer questions about birds'), 
    status: 2
  ),
  Challenge(
    name: 'Cool large rocks', 
    type: 'Checkpoints', 
    description: Text('Visit cool large rocks in Uppsala'), 
    status: 1,
  ),
  Challenge(
    name: 'Orienteering in Luthagen', 
    type: 'Orienteering', 
    description: Text('Gather control points in Luthagen'), 
    status: 1,
  ),
  Challenge(
    name: 'Questions about plants', 
    type: 'Quiz', 
    description: Text('Answer questions about plants'), 
    status: 2,
  ),
  Challenge(
    name: 'Important buildings', 
    type: 'Quiz', 
    description: Text('Answer questions about importnat buildings'), 
    status: 0
  ),
];