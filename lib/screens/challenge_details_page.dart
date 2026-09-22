import 'package:flutter/material.dart';

import '../models/challenge.dart';

class ChallengeDetailsPage extends StatelessWidget {
  final Challenge challenge;

  const ChallengeDetailsPage({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),

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
          'Challenge Details',
          style: TextStyle(
            color: Color(0xFF202735),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),

          const SizedBox(height: 16),

          _buildInformation(),

          const SizedBox(height: 16),

          _buildSkills(),

          const SizedBox(height: 20),

          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF087A40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(
              challenge.icon,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            challenge.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            challenge.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformation() {
    return _Card(
      title: 'Challenge Information',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: challenge.location,
          ),

          _InfoRow(
            icon: Icons.category_outlined,
            title: 'Category',
            value: challenge.category,
          ),

          _InfoRow(
            icon: Icons.flag_outlined,
            title: 'Priority',
            value: challenge.priority,
          ),

          _InfoRow(
            icon: Icons.info_outline,
            title: 'Status',
            value: challenge.status,
          ),

          _InfoRow(
            icon: Icons.tag,
            title: 'Challenge ID',
            value: challenge.id,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSkills() {
    return _Card(
      title: 'Required Skills',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: challenge.skills.map(
          (skill) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F5ED),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                skill,
                style: const TextStyle(
                  color: Color(0xFF087A40),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Challenge accepted successfully!',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.check),
            label: const Text(
              'Accept Challenge',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF087A40),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    'Collaboration request sent!',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.groups_outlined,
            ),
            label: const Text(
              'Collaborate',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(0xFF087A40),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              side: const BorderSide(
                color: Color(0xFF087A40),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202735),
            ),
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 16,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF087A40),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202735),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}