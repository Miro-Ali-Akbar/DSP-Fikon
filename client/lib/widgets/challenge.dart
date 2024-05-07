import 'package:flutter/material.dart';

class Challenge {
  final String type;
  final String name;
  final String description;
  int status;
  final String image;
  final int complete;
  int progress;
  final int points;

  Challenge({
    required this.type,
    required this.name,
    required this.description,
    required this.image,
    required this.complete,
    this.progress = 0,
    this.status = 0,
    this.points = 100
  });
}