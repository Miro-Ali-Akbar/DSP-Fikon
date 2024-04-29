import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

List<Challenge> challenges = <Challenge>[
  Challenge(
    name: '10 statues in Uppsala', 
    type: 'Checkpoints', 
    description: 'All around Uppsala there are plenty of interesting statues. During this checkpoint trail you will explore 10 of them.', 
    status: 0,
  ),
  Challenge(
    name: 'Questions about birds', 
    type: 'Quiz', 
    description:'Answer questions about birds', 
    status: 2
  ),
  Challenge(
    name: 'Cool large rocks', 
    type: 'Checkpoints', 
    description:'Visit cool large rocks in Uppsala', 
    status: 1,
  ),
  Challenge(
    name: 'Orienteering in Luthagen', 
    type: 'Orienteering', 
    description:'Gather control points in Luthagen', 
    status: 1,
  ),
  Challenge(
    name: 'Questions about plants', 
    type: 'Quiz', 
    description:'Answer questions about plants', 
    status: 2,
  ),
  Challenge(
    name: 'Important buildings', 
    type: 'Quiz', 
    description:'Answer questions about importnat buildings', 
    status: 0
  ),
];