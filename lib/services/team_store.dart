import 'package:flutter/material.dart';

import '../models/team_member.dart';

class TeamStore extends ChangeNotifier {
  TeamStore._();

  static final TeamStore instance =
      TeamStore._();

  final List<TeamMember> _members = [
    const TeamMember(
      id: 'TM-001',
      name: 'Abhi',
      role: 'Team Leader',
      department: 'Computer Science',
      email: 'abhi@example.com',
      isLeader: true,
    ),

    const TeamMember(
      id: 'TM-002',
      name: 'Rahul',
      role: 'Flutter Developer',
      department: 'Computer Science',
      email: 'rahul@example.com',
    ),

    const TeamMember(
      id: 'TM-003',
      name: 'Priya',
      role: 'UI/UX Designer',
      department: 'Computer Science',
      email: 'priya@example.com',
    ),

    const TeamMember(
      id: 'TM-004',
      name: 'Arun',
      role: 'Researcher',
      department: 'Civil Engineering',
      email: 'arun@example.com',
    ),
  ];

  List<TeamMember> get members =>
      List.unmodifiable(_members);

  int get memberCount => _members.length;

  void addMember(TeamMember member) {
    _members.add(member);
    notifyListeners();
  }

  void removeMember(String id) {
    _members.removeWhere(
      (member) => member.id == id,
    );

    notifyListeners();
  }
}