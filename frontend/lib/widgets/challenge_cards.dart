import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

final List<String> challengeTypes = <String>['Checkpoints', 'Quiz', 'Orienteering'];


class ChallengeCard extends StatefulWidget{
  final String type;
  final String name;
  final Text description;
  final bool timeLimit;

  const ChallengeCard({
    super.key,
    required this.name,
    required this.type,
    required this.description,
    required this.timeLimit
  });

  @override
  State<ChallengeCard> createState() => _CardState();
}

class _CardState extends State<ChallengeCard> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if(widget.type == 'Checkpoints') {
      return GestureDetector(
        onTap:() {
          setState(() {
            count++;
          });
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
      return Container(
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
                      '0/10 questions done',
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
      );
    }
    else if(widget.type == 'Orienteering') {
      return Container(
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
                      '0/10 control points',
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
      );
    }
    else {
      return Container(
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
      );
    }
  }
}