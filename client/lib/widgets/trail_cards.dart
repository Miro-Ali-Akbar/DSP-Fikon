import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trailquest/my_trail_list.dart';

import '../pages/individual_trail_page.dart';

final List<String> natureOptions = <String>['Nature', 'City', 'Both']; 

/**
 * Creates the trail cards
 */

class TrailCard extends StatefulWidget{
  final String name;
  final double lengthDistance; 
  final double lengthTime; 
  final String natureStatus; 
  final bool stairs; 
  final double heightDifference; 
  //final Image image; 

  const TrailCard({
    super.key,
    required this.name,
    required this.lengthDistance, 
    required this.lengthTime,
    required this.natureStatus, 
    required this.stairs, 
    required this.heightDifference,
    //required this.image
  });

  @override
  State<TrailCard> createState() => _TrailCardState();
}

class _TrailCardState extends State<TrailCard> {

  int index = 0; 

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          child: Container(
            width: 350,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Colors.green[400],
            ),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${widget.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
              pageBuilder: (context, x, xx) => IndividualTrailPage(trail: widget),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
          },
        );
  }

}