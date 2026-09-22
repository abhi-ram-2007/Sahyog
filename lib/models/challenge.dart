import 'package:flutter/material.dart';

class Challenge {
  final String id;
  final String title;
  final String location;
  final String category;
  final String priority;
  final String description;
  final List<String> skills;
  final String status;
  final IconData icon;

  const Challenge({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.priority,
    required this.description,
    required this.skills,
    required this.status,
    required this.icon,
  });
}