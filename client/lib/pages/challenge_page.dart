import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trailquest/challenges_list.dart';
import 'package:trailquest/pages/leaderboard_page.dart';
import 'package:trailquest/widgets/challenge_cards.dart';
import 'package:trailquest/main.dart';
import 'dart:convert';


const List<Widget> statusChallenge = <Widget>[
  Text('Not started'),
  Text('Ongoing'),
  Text('All')
];

const List<Widget> typeChallenge = <Widget>[
  Text('Time limit'),
  Text('Quiz'),
  Text('Checkpoints'),
  Text('Orienteering')
];

final List<bool> _selectedStatus = <bool>[false, false, true];
final List<bool> _selectedType = <bool>[false, false, false, false];

class ChallengePage extends StatefulWidget{
  ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengeState();
}

class _ChallengeState extends State<ChallengePage> {
  int score = 1000;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        appBar: AppBar(
          title: AutoSizeText('Your score is $score',
          style: TextStyle(fontSize: 20.0),
              maxLines: 2,
              minFontSize: 15.0,
              overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            TextButton.icon(
              onPressed: (){
                //  try {
                //   channel?.sink.add(jsonString);
                //   channel?.stream.listen((jsonString) {
                //     List<String> stringList = (jsonDecode(jsonString) as List<dynamic>).cast<String>();
                //     channel?.sink.close();
                    
                //   });
                  Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
                    pageBuilder: (context, x, xx) => Leaderboard(dataList),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    ));
                // } catch (e) {
                //   print(e);
                // }
                
              }, 
              label: Text('Leaderboard',
              style: TextStyle(
                color: Colors.white
              ),),
              icon: SvgPicture.asset('assets/images/img_group.svg'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              )
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 5),
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(120),
              child: AppBar(
                backgroundColor: Colors.green.shade600,
                actions: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child:OutlinedButton.icon(
                    onPressed: () {
                      for (int i = 0; i < _selectedStatus.length; i++) {
                            _selectedStatus[i] = i == _selectedStatus.length-1;
                          }
                      for (int i = 0; i < _selectedType.length; i++) {
                        _selectedType[i] = false;
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      minimumSize: Size(30, 20)
                    ),
                    label: Text('clear', style: TextStyle(color: Colors.white),),
                    icon: SvgPicture.asset('assets/images/img_cross.svg')
                    )
                  )
                ],
                
                flexibleSpace: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    ToggleButtons(
                      direction: Axis.vertical,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _selectedStatus.length; i++) {
                            _selectedStatus[i] = i == index;
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      borderColor: Colors.white,
                      selectedColor: Colors.black,
                      fillColor: Colors.white,
                      color: Colors.white,
                      constraints: const BoxConstraints(
                        minHeight: 30.0,
                        minWidth: 80.0
                      ),
                      isSelected: _selectedStatus,
                      children: statusChallenge,
                    ),]),
          
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          setState(() {
                            _selectedType[index] = !_selectedType[index];
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        borderColor: Colors.white,
                        selectedColor: Colors.black,
                        fillColor: Colors.white,
                        color: Colors.white,
                        constraints: const BoxConstraints(
                          minHeight: 30.0,
                          minWidth: 77.0,
                        ),
                        isSelected: _selectedType,
                        children: typeChallenge,
                      ),]
                    )
                  ],),
          
              ),
            ),
            body: scrollChallenges(context),
          ),
        )
      
      )
    );
  }
}

Widget scrollChallenges(BuildContext context) {
  return ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: challenges.length,
    itemBuilder: (context, index) {
      return challenges[index];
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
    
  );
}