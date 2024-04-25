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
            Row(
              children: [
                BackButton().build(context),
              ],
            ),
            Center(
              child: Column(
                children: [
                  Text('Leaderboard',
                    style: TextStyle(
                      color: Colors.green, 
                      fontSize: 30.0,
                    )
                  ),
                  ListView.builder(
                    itemCount: myList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(myList[index]),
                      );
                    }
                  )
                ],
              )
            )
          ],
        )   
      )
    );
  }
}


class BackButton extends StatelessWidget {

  @override 
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.pop(context); 
      }, 

      icon: SvgPicture.asset('assets/images/arrow-sm-left-svgrepo-com (1).svg',
        width: 40,
        height: 40,
        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn)
      ),

      label: Text(''), 
    ); 
  }
}