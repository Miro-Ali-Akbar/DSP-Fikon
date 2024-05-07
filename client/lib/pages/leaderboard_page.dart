import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trailquest/challenges_list.dart';
import 'package:trailquest/widgets/challenge_cards.dart';

class Leaderboard extends StatelessWidget {
  final List<dynamic> myList;

  // Constructor to receive the list
  Leaderboard(this.myList);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(

            //attempt att displaying a list not tested yet
            body: Column(
          children: [
            Row(children: [
              BackButton().build(context),
              Text('Leaderboard',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 30.0,
                  ))
            ]),
            Expanded(
              child: ListView.builder(
                  itemCount: myList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(myList[index]),
                    );
                  }),
            )
          ],
        )));
  }
}
