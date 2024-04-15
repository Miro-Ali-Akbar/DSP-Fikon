import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final List<String> entries = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
final List<int> colorCodes = <int>[600, 500, 100, 600, 500, 100, 600, 500, 100];

class ChallengePage extends StatelessWidget{
  ChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: Center(
          child: scrollChallenges(context)
        ), 
      ),
      
    );
  }
}

Widget scrollChallenges(BuildContext context) {
  return ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: entries.length,
    itemBuilder: (BuildContext context, int index) {
      return Container(
        height: 150,
        color: Colors.amber[colorCodes[index]],
        child: Center(child: Text('Challenge ${entries[index]}')),
      );
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  );
}