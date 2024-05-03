import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trailquest/challenges_list.dart';
import 'package:trailquest/widgets/challenge.dart';
import 'package:trailquest/pages/leaderboard_page.dart';
import 'package:trailquest/widgets/challenge_cards.dart';
import 'package:trailquest/main.dart';
import 'dart:convert';/**
 * The page where all challenge cards are displayed
*/

//Filters for the status of the challenge
const List<Widget> statusChallenge = <Widget>[
  Text('Not started'),
  Text('Ongoing'),
  Text('Done'),
  Text('All')
];

final List<bool> _selectedStatus = <bool>[false, false, false, true];


//Filters for the type of challenge
const List<Text> typeChallenge = <Text>[
  Text('Time limit'),
  Text('Treasure hunt'),
  Text('Checkpoints'),
  Text('Orienteering')
];

final List<bool> _selectedType = <bool>[false, false, false, false];

class ChallengePage extends StatefulWidget {
  ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengeState();
}

class _ChallengeState extends State<ChallengePage> {
  bool selected = false;
  
  int score = 1000;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
                'Your score is $score',
                style: TextStyle(fontSize: 20.0),
                maxLines: 2,
                minFontSize: 15.0,
                overflow: TextOverflow.ellipsis,
              ),
              actions: <Widget>[
                TextButton.icon(
                    onPressed: () {
                      channel?.sink.add('{"msgID": "getLeaderboard"}');
                      Navigator.of(context, rootNavigator: true)
                          .push(PageRouteBuilder(
                        pageBuilder: (context, x, xx) => Leaderboard(dataList),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ));
                    },
                    label: Text(
                      'Leaderboard',
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: SvgPicture.asset('assets/images/img_group.svg'),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 30),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    )),
              ],
        ),
        body: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(150),
            child: AppBar(
              backgroundColor: Colors.green.shade600,
              actions: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  // 'clear' button that unselects all selected filters
                  child:OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (int i = 0; i < _selectedStatus.length; i++) {
                          _selectedStatus[i] = i == _selectedStatus.length-1;
                        }
                        for (int i = 0; i < _selectedType.length; i++) {
                          _selectedType[i] = false;
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      minimumSize: Size(30, 20)
                    ),
                    label: Text('clear', style: TextStyle(color: Colors.white),),
                    icon: SvgPicture.asset('assets/icons/img_cross.svg')
                  )
                )
              ],
              
              flexibleSpace: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    // Filter buttons for the status of a challenge (ongoing etc)
                    ToggleButtons(
                      direction: Axis.vertical,
                      onPressed: (int index) {
                        setState(() {
                          for (int i = 0; i < _selectedStatus.length; i++) {
                            _selectedStatus[i] = i == index;
                          }
                        });
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderColor: Colors.white,
                      selectedColor: Colors.black,
                      fillColor: Colors.white,
                      color: Colors.white,
                      constraints: const BoxConstraints(
                        minHeight: 30.0,
                        minWidth: 100.0
                      ),
                      isSelected: _selectedStatus,
                      children: statusChallenge,
                    ),]
                  ),

                  // Filter buttons for the type of challenge
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                    height: 90,
                    width: 200,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(bottom: 6),
                    child: 
                      GridView.count(
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 5/2,
                        crossAxisCount: 2,
                        // If we want to add more filters, this is where we do it as well as the lists at the top
                        children: [
                          Text('Time limit'),
                          Text('Treasure hunt'),
                          Text('Checkpoints'),
                          Text('Orienteering')
                        ].asMap().entries.map((widget) {
                          return ToggleButtons(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            borderColor: Colors.white,
                            selectedColor: Colors.black,
                            fillColor: Colors.white,
                            color: Colors.white, 
                            constraints: const BoxConstraints(
                              minHeight: 30.0,
                              minWidth: 85.0,
                            ),
                            isSelected: [_selectedType[widget.key]],
                            onPressed: (int index) {
                              setState(() {
                                _selectedType[widget.key] = !_selectedType[widget.key];
                              });
                            },
                            children: [widget.value],
                          );
                        }).toList()
                      )
                    ),
                  )
                ],
              ),
            ),
          ),
          body: scrollChallenges(context),
        )
      )
    );
  }
}

// Creates the scrollable view of challenge cards
Widget scrollChallenges(BuildContext context) {
  List<Challenge> current = filterChallenges(context, challenges);
  return ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: current.length,
    itemBuilder: (context, index) {
      return ChallengeCard(current[index], challenge: current[index],);
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  );
}

// Filters the list of challenges depending on what filters are true (active) in the filter buttons
List<Challenge> filterChallenges(BuildContext context, List<Challenge> list) {
  List<String?> activeTypes = [];
  int activeStatus = 3; //defalut is 'all'

  for(int i = 0; i < _selectedStatus.length; i++) {
    if(_selectedStatus[i]) {
      activeStatus = i;
    }    
  }

  for(int i = 0; i < _selectedStatus.length; i++) {
    if(_selectedStatus[i]) {
      activeStatus = i;
    }    
  }
  
  for(int i = 0; i < _selectedType.length; i++) {
    if(_selectedType[i]) { 
      String? type = typeChallenge[i].data;
      activeTypes.add(type);
    }
  }

  if(activeTypes.length == 0 && activeStatus > 2) {
    return list;

  } else {
    List<Challenge> filteredChallenges = [];
    if(activeTypes.length > 0 && activeStatus < 3) {
      for(int i = 0; i < list.length; i++) {
        for(int j = 0; j < activeTypes.length; j++) {
            if(activeTypes[j] == list[i].type && list[i].status == activeStatus) {
              filteredChallenges.add(list[i]);
            }
          }
      }
    } else {
      for(int i = 0; i < list.length; i++) {
        if(list[i].status == activeStatus) {
          filteredChallenges.add(list[i]);
        } else {
          for(int j = 0; j < activeTypes.length; j++) {
            if(activeTypes[j] == list[i].type) {
              filteredChallenges.add(list[i]);
            }
          }
        }
      }
    }
    if(filteredChallenges.length == 0) {
      return list;
    } else {
      return filteredChallenges;
    }
  }
}
