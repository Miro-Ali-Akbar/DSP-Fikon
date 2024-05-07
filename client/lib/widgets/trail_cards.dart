import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pages/individual_trail_page.dart';

final List<String> natureOptions = <String>['Nature', 'City', 'Both']; 

/**
 * Creates the trail cards
 */

class TrailCard extends StatefulWidget{
  late String name;
  late double lengthDistance; 
  late double lengthTime; 
  late String natureStatus; 
  late bool stairs; 
  late double heightDifference; 
  bool isSaved; 
  bool isCircular; 
  //final ValueChanged<bool> onSaveChanged;
  final String image_path; 
  //TODO: Add list of coordinates 

  TrailCard({
    super.key,
    required this.name,
    required this.lengthDistance, 
    required this.lengthTime,
    required this.natureStatus, 
    required this.stairs, 
    required this.heightDifference,
    required this.isSaved, 
    required this.isCircular,
    required this.image_path, 
    //required this.onSaveChanged, // Callback function
    //TODO: add list of coordinates 
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
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
              child: Image.asset(
                widget.image_path,
                width: 170, 
                height: 120, 
                alignment: Alignment.centerLeft,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ 
                Text(
                    '${widget.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                ),
                Text(
                  '${widget.lengthTime} min',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${widget.lengthDistance/1000} km',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
          pageBuilder: (context, x, xx) => IndividualTrailPage(
            trail: widget, 
            saved: widget.isSaved,
            onSaveChanged: (value) {
              setState(() {
                widget.isSaved = value; // Update the isSaved variable in the TrailCard
              });
            },
          ),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ));
      },
    );
  }
}