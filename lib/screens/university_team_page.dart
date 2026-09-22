import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../services/team_store.dart';

class UniversityTeamPage extends StatefulWidget {
  const UniversityTeamPage({
    super.key,
  });

  @override
  State<UniversityTeamPage> createState() =>
      _UniversityTeamPageState();
}

class _UniversityTeamPageState
    extends State<UniversityTeamPage> {
  final TeamStore store = TeamStore.instance;

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
          'My Team',
          style: TextStyle(
            color: Color(0xFF202735),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xFF087A40),
        onPressed: _showAddMemberDialog,
        child: const Icon(
          Icons.person_add_alt_1,
          color: Colors.white,
        ),
      ),

      body: Column(
        children: [
          _buildTeamHeader(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.members.length,
              itemBuilder: (context, index) {
                return _MemberCard(
                  member: store.members[index],
                  onDelete: () {
                    store.removeMember(
                      store.members[index].id,
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

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F5ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_outlined,
              size: 32,
              color: Color(0xFF087A40),
            ),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Team',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202735),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${store.memberCount} team members',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameController =
        TextEditingController();
    final roleController =
        TextEditingController();
    final departmentController =
        TextEditingController();
    final emailController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add Team Member',
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Name',
                  ),
                ),

                TextField(
                  controller: roleController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Role',
                  ),
                ),

                TextField(
                  controller:
                      departmentController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Department',
                  ),
                ),

                TextField(
                  controller: emailController,
                  decoration:
                      const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (nameController
                        .text
                        .trim()
                        .isEmpty ||
                    roleController
                        .text
                        .trim()
                        .isEmpty) {
                  return;
                }

                store.addMember(
                  TeamMember(
                    id:
                        'TM-${DateTime.now().millisecondsSinceEpoch}',
                    name:
                        nameController.text.trim(),
                    role:
                        roleController.text.trim(),
                    department:
                        departmentController
                            .text
                            .trim(),
                    email:
                        emailController.text.trim(),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text(
                'Add',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MemberCard extends StatelessWidget {
  final TeamMember member;
  final VoidCallback onDelete;

  const _MemberCard({
    required this.member,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor:
                const Color(0xFFE7F5ED),
            child: Text(
              member.name.isNotEmpty
                  ? member.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Color(0xFF087A40),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF202735),
                        ),
                      ),
                    ),

                    if (member.isLeader) ...[
                      const SizedBox(width: 6),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration:
                            BoxDecoration(
                          color: const Color(
                            0xFFE7F5ED,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child: const Text(
                          'Leader',
                          style: TextStyle(
                            color: Color(
                              0xFF087A40,
                            ),
                            fontSize: 9,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  member.role,
                  style: const TextStyle(
                    color: Color(0xFF087A40),
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  member.department,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          if (!member.isLeader)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'remove') {
                  onDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'remove',
                  child: Text(
                    'Remove',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}