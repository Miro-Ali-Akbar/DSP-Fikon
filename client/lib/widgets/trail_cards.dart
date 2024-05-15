import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:trailquest/pages/individual_trail_page.dart';

final List<String> natureOptions = <String>['Nature', 'City', 'Both'];

/// Defines the properties of the trail cards

class TrailCard extends StatefulWidget {
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
  late List<LatLng> coordinates;

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
    //required this.onSaveChanged, // Callback function
    required this.image_path,
    required this.coordinates,
  });

  @override
  State<TrailCard> createState() => _TrailCardState();
}

class _TrailCardState extends State<TrailCard> {
  /// Builds the trail cards that are dispalayed on the Trail Page

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      ///
      /// This defines the shape, size, color etc. of the trail cards
      ///
      child: Container(
        width: 350,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.green[400],
        ),

        ///
        /// The defines the contents of the trail cards
        ///
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
            SizedBox(
              width: 10,
            ),
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
                  '${(widget.lengthTime).toStringAsFixed(1)} min',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${(widget.lengthDistance / 1000).toStringAsFixed(1)} km',
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

      ///
      /// When a trail card is pressed, it will transition to the individual trail page
      /// coresponding with the trail that was pressed
      ///
      onTap: () {
        //fetchTrailsFromServer();
        Navigator.of(context, rootNavigator: true).push(
          PageRouteBuilder(
            pageBuilder: (context, x, xx) => IndividualTrailPage(
              trail: widget,
              saved: widget.isSaved,

              ///
              /// This function is used to handle saving/removing trails in the individual trail page
              ///
              onSaveChanged: (value) {
                setState(() {
                  widget.isSaved =
                      value; // Update the isSaved variable in the TrailCard
                });
              },
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
    );
  }
}
