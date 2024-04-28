import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/pages/individual_challenge_page.dart';

final List<String> challengeTypes = <String>['Checkpoints', 'Quiz', 'Orienteering'];

/**
 * Creates the cards that will be visible on the challenge page and start page.
 * As of now, the accepted types are 'Checkpoints', 'Orienteering' and 'Quiz' but it's likely that Quiz will be substituted for 'Straight line'
 */

class Challenge extends StatefulWidget{
  final String type;
  final String name;
  final Text description;
  final int status;

  const Challenge({
    super.key,
    required this.name,
    required this.type,
    required this.description,
    required this.status
  });

  @override
  State<Challenge> createState() => _CardState();
}

class _CardState extends State<Challenge> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if(widget.type == 'Checkpoints') {
      return GestureDetector(
        onTap:() {
          // This is where we can add navigation to the page that will display more detailed information about the challenge
          /*Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
              pageBuilder: (context, x, xx) => IndividualChallengePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));*/
        },
        child: Container(
          height: 150,
          color: const Color.fromARGB(255, 89, 164, 224),
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      '${widget.name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(35)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ 
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '$count/10 checkpoints',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: SvgPicture.asset(
                          'assets/images/img_arrow_right.svg',
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      )
                    ),
                  ],
                )
              ],
            )
          )
        ),
      );
    }
    else if(widget.type == 'Quiz') {
      return GestureDetector(
        onTap:() {
          // This is where we can add navigation to the page that will display more detailed information about the challenge
          setState(() {
            count++;
          });
        },
        child: Container(
          height: 150,
          color: Color.fromARGB(255, 250, 159, 74),
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      '${widget.name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(35)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ 
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '$count/10 questions done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: SvgPicture.asset(
                          'assets/images/img_arrow_right.svg',
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      )
                    ),
                  ],
                )
              ],
            )
          )
        ),
      );
    }
    else if(widget.type == 'Orienteering') {
      return GestureDetector(
        onTap:() {
          // This is where we can add navigation to the page that will display more detailed information about the challenge
          setState(() {
            count++;
          });
        },
        child: Container(
          height: 150,
          color: Color.fromARGB(255, 137, 70, 196),
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '${widget.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(35)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ 
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '$count/10 control points',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: SvgPicture.asset(
                          'assets/images/img_arrow_right.svg',
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      )
                    ),
                  ],
                )
              ],
            )
          )
        ),
      );
    }
    else {
      // A default challenge that does not belong to any of the given types, not meant to actually be used
      return GestureDetector(
        onTap:() {},
        child: Container(
          height: 150,
          color: Color.fromARGB(255, 92, 95, 97),
        
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      '${widget.name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(35)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ 
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'no info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: SvgPicture.asset(
                          'assets/images/img_arrow_right.svg',
                          height: 20,
                          width: 20,
                          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      )
                    ),
                  ],
                )
              ],
            )
          )
        ),
      );
    }
  }
}