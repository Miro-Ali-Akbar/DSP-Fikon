import 'package:flutter/material.dart';

class Challenge {
  final String type;
  final String name;
  final Text description;
  int status;

  Challenge({
    required this.type,
    required this.name,
    required this.description,
    required this.status
  });
}