import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

List<Challenge> challenges = <Challenge>[
  Challenge(
    name: '10 statues in Uppsala', 
    type: 'Checkpoints', 
    description: 'All around Uppsala there are plenty of interesting statues. During this checkpoint trail you will explore 10 of them.', 
    status: 0,
    image: 'assets/images/img_image_1.png'
  ),
  Challenge(
    name: 'Birds', 
    type: 'Orienteering', 
    description:'Visit all marked control points and maybe you will get to see some cool birds. No gurantee though, despite the name of the challenge.', 
    status: 2,
    image: 'assets/images/img_image_1.png'
  ),
  Challenge(
    name: 'Cool large rocks', 
    type: 'Treasure hunt', 
    description:'We have found som very cool large rocks around Uppsala. Are you willing to take on the quest to find them all?', 
    status: 1,
    image: 'assets/images/img_image_1.png'
  ),
  Challenge(
    name: 'Orienteering in Luthagen', 
    type: 'Orienteering', 
    description:"Gather control points in Luthagen. Why? It's pretty nice here actually.", 
    status: 1,
    image: 'assets/images/img_image_1.png'
  ),
  Challenge(
    name: 'Pretty flowers', 
    type: 'Checkpoints', 
    description:'Walk the trail and look at the pretty flowers at each checkpoint. Maybe smell them too?', 
    status: 2,
    image: 'assets/images/img_image_1.png'
  ),
  Challenge(
    name: 'Important buildings', 
    type: 'Treasure hunt', 
    description:"This will take you to some of the important buildings in Uppsala. You won't know which ones beforehand so follow the trails and see where they lead. Can you guess all the buildings?", 
    status: 0,
    image: 'assets/images/img_image_1.png'
  ),
];