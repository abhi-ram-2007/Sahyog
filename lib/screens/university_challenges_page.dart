import 'package:flutter/material.dart';

import '../models/challenge.dart';
import '../services/challenge_store.dart';
import 'challenge_details_page.dart';

class UniversityChallengesPage extends StatefulWidget {
  const UniversityChallengesPage({
    super.key,
  });

  @override
  State<UniversityChallengesPage> createState() =>
      _UniversityChallengesPageState();
}

class _UniversityChallengesPageState
    extends State<UniversityChallengesPage> {
  final ChallengeStore store =
      ChallengeStore.instance;

  String selectedFilter = 'All';

  final List<String> filters = [
    'All',
    'New',
    'In Progress',
    'Completed',
  ];

  List<Challenge> get filteredChallenges {
    if (selectedFilter == 'All') {
      return store.challenges;
    }

    return store.challenges
        .where(
          (challenge) =>
              challenge.status == selectedFilter,
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();

    store.addListener(_refresh);
  }

  @override
  void dispose() {
    store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F8F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF202735),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Challenges',
          style: TextStyle(
            color: Color(0xFF202735),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildFilters(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount:
                  filteredChallenges.length,
              itemBuilder: (context, index) {
                final challenge =
                    filteredChallenges[index];

                return _ChallengeCard(
                  challenge: challenge,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChallengeDetailsPage(
                          challenge: challenge,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 62,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected =
              filter == selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              margin:
                  const EdgeInsets.only(
                right: 8,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF087A40)
                    : const Color(0xFFE7F5ED),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : const Color(0xFF087A40),
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      const Color(0xFFE7F5ED),
                  child: Icon(
                    challenge.icon,
                    color:
                        const Color(0xFF087A40),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF202735),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Color(0xFF6B7280),
                ),

                const SizedBox(width: 5),

                Expanded(
                  child: Text(
                    challenge.location,
                    style: const TextStyle(
                      color:
                          Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _tag(challenge.category),
                _tag(
                  '${challenge.priority} Priority',
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              challenge.description,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTap,
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(0xFF087A40),
                  side: const BorderSide(
                    color: Color(0xFF087A40),
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                child: const Text(
                  'View Challenge',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F5ED),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF087A40),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}