import 'package:flutter/material.dart';
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
  bool isSaved; 
  //final ValueChanged<bool> onSaveChanged;
  //final Image image; 
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
    //required this.onSaveChanged, // Callback function
    });
    //required this.image
    //TODO: add list of coordinates 

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