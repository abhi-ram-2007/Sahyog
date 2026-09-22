import 'package:flutter/material.dart';

import '../models/challenge.dart';

class ChallengeStore extends ChangeNotifier {
  ChallengeStore._();

  static final ChallengeStore instance =
      ChallengeStore._();

  final List<Challenge> _challenges = [
    const Challenge(
      id: 'CH-001',
      title: 'Drainage blockage in my locality',
      location: 'Ward 12, Rajampet',
      category: 'Sanitation',
      priority: 'High',
      description:
          'Develop a practical solution to identify drainage blockages and provide timely alerts to the concerned authorities.',
      skills: [
        'IoT',
        'Sanitation',
        'Environmental Engineering',
      ],
      status: 'New',
      icon: Icons.water_damage_outlined,
    ),

    const Challenge(
      id: 'CH-002',
      title: 'Water shortage in rural area',
      location: 'Ananthapur',
      category: 'Water Management',
      priority: 'Medium',
      description:
          'Design an affordable and sustainable solution for monitoring and managing water availability in rural communities.',
      skills: [
        'Water Management',
        'IoT',
        'Civil Engineering',
      ],
      status: 'New',
      icon: Icons.water_drop_outlined,
    ),

    const Challenge(
      id: 'CH-003',
      title: 'Smart waste collection system',
      location: 'Kadapa',
      category: 'Waste Management',
      priority: 'High',
      description:
          'Create a technology-based system to improve waste collection and identify overflowing waste bins.',
      skills: [
        'IoT',
        'AI',
        'Waste Management',
      ],
      status: 'In Progress',
      icon: Icons.delete_outline,
    ),

    const Challenge(
      id: 'CH-004',
      title: 'Smart streetlight monitoring',
      location: 'Rajampet',
      category: 'Infrastructure',
      priority: 'Medium',
      description:
          'Develop a system for detecting faulty streetlights and reporting them automatically.',
      skills: [
        'IoT',
        'Electronics',
        'Mobile Development',
      ],
      status: 'New',
      icon: Icons.lightbulb_outline,
    ),
  ];

  List<Challenge> get challenges =>
      List.unmodifiable(_challenges);

  List<Challenge> get assignedChallenges =>
      List.unmodifiable(_challenges);

  int get newChallenges => _challenges
      .where((challenge) => challenge.status == 'New')
      .length;

  int get inProgressChallenges => _challenges
      .where(
        (challenge) =>
            challenge.status == 'In Progress',
      )
      .length;

  int get completedChallenges => _challenges
      .where(
        (challenge) =>
            challenge.status == 'Completed',
      )
      .length;

  void addChallenge(Challenge challenge) {
    _challenges.insert(0, challenge);
    notifyListeners();
  }

  void updateStatus(
    String challengeId,
    String status,
  ) {
    final index = _challenges.indexWhere(
      (challenge) => challenge.id == challengeId,
    );

    if (index == -1) return;

    final oldChallenge = _challenges[index];

    _challenges[index] = Challenge(
      id: oldChallenge.id,
      title: oldChallenge.title,
      location: oldChallenge.location,
      category: oldChallenge.category,
      priority: oldChallenge.priority,
      description: oldChallenge.description,
      skills: oldChallenge.skills,
      status: status,
      icon: oldChallenge.icon,
    );

    notifyListeners();
  }
}