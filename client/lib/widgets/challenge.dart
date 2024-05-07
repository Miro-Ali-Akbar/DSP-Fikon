/// Contains all information about a challenge
/// As of now, the permitted challenge types are 'Checkpoints', 'Orienteering' and 'Treasure hunt'
class Challenge {
  final String type;
  final String name;
  final String description;
  int status;
  final String image;

  Challenge({
    required this.type,
    required this.name,
    required this.description,
    required this.status,
    required this.image
  });
}