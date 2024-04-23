import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trailquest/challenges_list.dart';
import 'package:trailquest/widgets/filter_buttons.dart';

/**
 * The page where all challenge cards are displayed
*/

//Filter buttons for the status of the challenge
const List<Widget> statusChallenge = <Widget>[
  Text('Not started'),
  Text('Ongoing'),
  Text('All')
];

final List<bool> _selectedStatus = <bool>[false, false, true];


//Filter buttons for the type of challenge
const List<Widget> typeChallenge = <Widget>[
  Text('Time limit'),
  Text('Quiz'),
  Text('Checkpoints'),
  Text('Orienteering')
];

final List<bool> _selectedType = <bool>[false, false, false, false];

class ChallengePage extends StatefulWidget{
  ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengeState();
}

class _ChallengeState extends State<ChallengePage> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          // should be substituted for the leaderboard button and the user's score
          title: const Text('Challenges'),
        ),
        body: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(130),
            child: AppBar(
              backgroundColor: Colors.green.shade600,
              actions: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  // 'clear' button that should unselect all selected filters
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
                        minWidth: 80.0
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
                      Expanded(
                        child: FilterButtons(selected: _selectedType,)
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
  return ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: challenges.length,
    itemBuilder: (context, index) {
      return challenges[index];
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  );
}