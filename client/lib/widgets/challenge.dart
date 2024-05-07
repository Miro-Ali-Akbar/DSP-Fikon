/// Contains all information about a challenge
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