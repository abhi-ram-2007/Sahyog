import 'package:flutter/material.dart';

class ReportUpdate {
  final String title;
  final String description;
  final DateTime date;
  final bool completed;

  const ReportUpdate({
    required this.title,
    required this.description,
    required this.date,
    required this.completed,
  });
}

class Report {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String status;
  final String priority;
  final String department;
  final DateTime submittedAt;
  final IconData icon;
  final String? imagePath;
  final List<ReportUpdate> updates;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    required this.priority,
    required this.department,
    required this.submittedAt,
    required this.icon,
    this.imagePath,
    List<ReportUpdate>? updates,
  }) : updates = updates ?? [];

  Report copyWith({
    String? status,
    List<ReportUpdate>? updates,
  }) {
    return Report(
      id: id,
      title: title,
      description: description,
      location: location,
      category: category,
      status: status ?? this.status,
      priority: priority,
      department: department,
      submittedAt: submittedAt,
      icon: icon,
      imagePath: imagePath,
      updates: updates ?? this.updates,
    );
  }
}