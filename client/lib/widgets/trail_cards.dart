import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../pages/individual_trail_page.dart';

final List<String> natureOptions = <String>['Nature', 'City', 'Both'];

/**
 * Creates the trail cards
 */

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
  //final Image image;
  //TODO: Add list of coordinates
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
    required this.coordinates,
  });
  //required this.image
  //TODO: add list of coordinates

  @override
  State<TrailCard> createState() => _TrailCardState();
}

class _TrailCardState extends State<TrailCard> {
  int index = 0;

  late TrailCard currentTrail;

  //TODO: Fetch from database, simulated data below
  void fetchTrailsFromServer() {
    var trailsData = [
      {
        "trailName": "Test trail",
        "totalDistance": 31.0,
        "totalTime": 0.363849765258216,
        "statusEnvironment": "Both",
        "avoidStairs": false,
        "hilliness": 0.09058952331542969,
        "coordinates": [
          {"latitude": 59.85697, "longitude": 17.62699},
          {"latitude": 59.85695, "longitude": 17.62704},
          {"latitude": 59.8569, "longitude": 17.62693},
          {"latitude": 59.85692, "longitude": 17.62688},
          {"latitude": 59.8569, "longitude": 17.62693},
          {"latitude": 59.85686, "longitude": 17.62699},
          {"latitude": 59.8569, "longitude": 17.62693},
          {"latitude": 59.85695, "longitude": 17.62704},
          {"latitude": 59.8569, "longitude": 17.62712},
          {"latitude": 59.85695, "longitude": 17.62704}
        ]
      },
    ];

    for (var data in trailsData) {
      List<LatLng> trailCoordinates = [];
      var coordinatesData = data['coordinates'];
      if (coordinatesData != null && coordinatesData is List) {
        trailCoordinates = List<LatLng>.from(coordinatesData
            .map((coord) => LatLng(coord['latitude'], coord['longitude'])));
      }

      currentTrail = TrailCard(
          name: data['trailName'].toString(),
          lengthDistance: data['totalDistance'] as double,
          lengthTime: data['totalTime'] as double,
          natureStatus: data['statusEnvironment'] as String,
          stairs: data['avoidStairs'] as bool,
          heightDifference: data['hilliness'] as double,
          isSaved: true,
          isCircular: false,
          coordinates: trailCoordinates);
    }

    setState(() {});
  }

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
        fetchTrailsFromServer();
        Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
          pageBuilder: (context, x, xx) => IndividualTrailPage(
            trail: currentTrail,
            saved: currentTrail.isSaved,
            onSaveChanged: (value) {
              setState(() {
                currentTrail.isSaved =
                    value; // Update the isSaved variable in the TrailCard
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
