import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Contains all information about a challenge
/// As of now, the permitted challenge types are 'Checkpoints', 'Orienteering' and 'Treasure hunt'
class Challenge {
  final String type;
  final String name;
  final String description;
  final String dataType;
  int status;
  final String image;
  final int complete;
  int progress;
  final int points;
  List<LatLng> claimedPoints;

  Challenge({
    required this.type,
    required this.name,
    required this.description,
    required this.dataType,
    required this.image,
    required this.complete,
    required this.claimedPoints,
    this.progress = 0,
    this.status = 0,
    this.points = 100,
  });
}
