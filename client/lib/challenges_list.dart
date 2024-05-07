import 'package:flutter/material.dart';
import 'package:trailquest/widgets/challenge.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

List<Challenge> challenges = <Challenge>[
  Challenge(
    name: '10 statues in Uppsala',
    type: 'Checkpoints',
    description:
        'All around Uppsala there are plenty of interesting statues. During this checkpoint trail you will explore 10 of them.',
    dataType: 'statues',
    status: 0,
    image: 'assets/images/Pelle_Svanslös-statyn.jpg',
    complete: 10,
  ),
  Challenge(
      name: 'Birds',
      type: 'Orienteering',
      description:
          'Visit all marked control points and maybe you will get to see some cool birds. No gurantee though, despite the name of the challenge.',
      dataType: 'birds',
      status: 2,
      image: 'assets/images/gardsmyg_johan-nilsson.jpg',
      complete: 12),
  Challenge(
      name: 'Cool large rocks',
      type: 'Treasure hunt',
      description:
          'We have found som very cool large rocks around Uppsala. Are you willing to take on the quest to find them all?',
      dataType: 'rocks',
      status: 1,
      image: 'assets/images/FlyttblockSurte.jpg',
      complete: 7),
  Challenge(
      name: 'Orienteering in Luthagen',
      type: 'Orienteering',
      description:
          "Gather control points in Luthagen. Why? It's pretty nice here actually.",
      dataType: 'luthagen',
      status: 1,
      image: 'assets/images/Luthagen.jpg',
      complete: 8),
  Challenge(
      name: 'Pretty flowers',
      type: 'Checkpoints',
      description:
          'Walk the trail and look at the pretty flowers at each checkpoint. Maybe smell them too?',
      dataType: 'flowers',
      status: 2,
      image: 'assets/images/wildflowers.jpg',
      complete: 9),
  Challenge(
      name: 'Important buildings',
      type: 'Treasure hunt',
      description:
          "This will take you to some of the important buildings in Uppsala. You won't know which ones beforehand so follow the trails and see where they lead. Can you guess all the buildings?",
      dataType: 'buildings',
      status: 0,
      image: 'assets/images/Uppsala_domkyrka_flygbild.jpg',
      complete: 5),
];
