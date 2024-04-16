import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trailquest/widgets/filter_buttons.dart';


final List<String> entries = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
final List<int> colorCodes = <int>[600, 500, 300, 600, 500, 300, 600, 500, 300];



class ChallengePage extends StatefulWidget{
  ChallengePage({super.key});

  @override
  State<ChallengePage> createState() => _ChallengeState();
}

class _ChallengeState extends State<ChallengePage> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    bool selectedNotStarted = false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        appBar: AppBar(
          title: const Text('Challenges'),
        ),
        body: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(160),
            child: AppBar(
              backgroundColor: Colors.green.shade600,
              actions: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white)
                  ),
                  child: Text('clear  x', style: TextStyle(color: Colors.white),),
                )
              ],

              flexibleSpace: Row(
                children: [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                  Column(
                    children: [
                      /*FilterButton(
                        title: 'test'
                      ),
                      
                      TextButton(
                        onPressed: () {}, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white)
                        ),
                        child: Text(
                          'Ongoing', 
                          style: 
                          TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {}, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white)
                        ),
                        child: Text(
                          'All', 
                          style: 
                          TextStyle(color: Colors.black),
                        ),
                      )*/
                    ],
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 30)),
                  Column(children: [
                    /*Padding(padding: EdgeInsets.symmetric(vertical: 23)),
                    TextButton(
                        onPressed: () {}, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white)
                        ),
                        child: Text(
                          'Time limit', 
                          style: 
                          TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {}, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white)
                        ),
                        child: Text(
                          'Checkpoints', 
                          style: 
                          TextStyle(color: Colors.black),
                        ),
                      )
                  */],),
                  Column(children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 23)),
                    TextButton(
                        onPressed: () {}, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white)
                        ),
                        child: Text(
                          'Distance', 
                          style: 
                          TextStyle(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {}, 
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white)
                        ),
                        child: Text(
                          'Steps', 
                          style: 
                          TextStyle(color: Colors.black),
                        ),
                      )
                  ],),
                ],),

            ),
          ),
          body: FilterButton(
            title: 'test',
          )//scrollChallenges(context),
        )
      
      )
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
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Challenge ${entries[index]}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(35)),
              Row(
                children: [ 
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '0/10 checkpoints',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 90)),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: SvgPicture.asset(
                      'assets/images/img_arrow_right.svg',
                      height: 20,
                      width: 20,
                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    )
                  )
                ],
              )
            ],
          )
        )
      );
    },
    separatorBuilder: (BuildContext context, int index) => const Divider(),
  );
}