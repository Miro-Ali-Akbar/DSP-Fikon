import 'package:flutter/material.dart';

class Challenge {
  final String type;
  final String name;
  final String description;
  int status;
  final String image;
  final int complete;
  int progress;

  Challenge({
    required this.type,
    required this.name,
    required this.description,
    required this.status,
    required this.image,
    required this.complete,
    this.progress = 0
  });
}