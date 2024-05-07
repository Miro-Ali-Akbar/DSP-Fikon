import 'package:trailquest/widgets/challenge.dart';

/// A list of all challenges currently available in the application and information about them
List<Challenge> challenges = <Challenge>[
  Challenge(
    name: '5 statues in Uppsala',
    type: 'Checkpoints',
    description:
        'All around Uppsala there are some interesting statues. During this checkpoint trail you will explore 10 of them.',
    dataType: 'statues',
    image: 'assets/images/Pelle_Svanslös-statyn.jpg',
    complete: 5
  ),
  Challenge(
      name: 'Birds',
      type: 'Orienteering',
      description:
          'Visit all marked control points and maybe you will get to see some cool birds. No gurantee though, despite the name of the challenge.',
      dataType: 'birds',
      image: 'assets/images/gardsmyg_johan-nilsson.jpg',
      complete: 12),
  Challenge(
      name: 'Cool large rocks',
      type: 'Treasure hunt',
      description:
          'We have found some very cool large rocks around Uppsala. Are you willing to take on the quest to find them all?',
      dataType: 'rocks',
      image: 'assets/images/FlyttblockSurte.jpg',
      complete: 4),
  Challenge(
      name: 'Orienteering in Luthagen',
      type: 'Orienteering',
      description:
          "Gather control points in Luthagen. Why? It's pretty nice here actually.",
      dataType: 'luthagen',
      image: 'assets/images/Luthagen.jpg',
      complete: 8),
  Challenge(
      name: 'Pretty flowers',
      type: 'Checkpoints',
      description:
          'Walk the trail and look at the pretty flowers at each checkpoint. Maybe smell them too?',
      dataType: 'flowers',
      image: 'assets/images/wildflowers.jpg',
      complete: 9
 
  ),
  Challenge(
      name: 'Important buildings',
      type: 'Treasure hunt',
      description:
          "This will take you to some of the important buildings in Uppsala. You won't know which ones beforehand so follow the trails and see where they lead. Can you guess all the buildings?",
      dataType: 'buildings',
      image: 'assets/images/Uppsala_domkyrka_flygbild.jpg',
      complete: 5),
  Challenge(
      name: 'DEMO Orienteering',
      type: 'Orienteering',
      description:
          "Current position disabled. This is a demo of how the challenges-system works. This challenge is semi-representative of how a normal challenge works. Normally it is larger and based on some sort of data to be dynamic.",
      dataType: 'demo',
      status: 0,
      // TODO: Change image
      image: 'assets/images/Uppsala_domkyrka_flygbild.jpg',
      complete: 1),
  Challenge(
      name: 'DEMO Checkpoints',
      type: 'Checkpoints',
      description:
          "Current position enabled. This is a demo of how the challenges-system works. This challenge is semi-representative of how a normal challenge works. Normally it is larger and based on some sort of data to be dynamic.",
      dataType: 'demo',
      status: 0,
      // TODO: Change image
      image: 'assets/images/Uppsala_domkyrka_flygbild.jpg',
      complete: 1),
];
