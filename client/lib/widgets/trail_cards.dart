import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  late List<LatLng> coordinates; 
  //final ValueChanged<bool> onSaveChanged;
  //final Image image;

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
    required this.coordinates,
    //required this.onSaveChanged, // Callback function
    });
    //required this.image

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