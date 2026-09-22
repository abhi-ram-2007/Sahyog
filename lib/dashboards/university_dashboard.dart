import 'package:flutter/material.dart';

import '../screens/profile_page.dart';
import '../widgets/profile_button.dart';

import '../models/challenge.dart';
import '../services/challenge_store.dart';
import '../services/team_store.dart';
import '../services/report_assignment_store.dart';

import '../screens/challenge_details_page.dart';
import '../screens/university_challenges_page.dart';
import '../screens/university_team_page.dart';

class UniversityDashboard extends StatefulWidget {
  const UniversityDashboard({super.key});

  static const Color primaryGreen = Color(0xFF087A40);
  static const Color lightGreen = Color(0xFFE7F5ED);
  static const Color background = Color(0xFFF6F8F7);
  static const Color darkText = Color(0xFF202735);
  static const Color greyText = Color(0xFF6B7280);

  @override
  State<UniversityDashboard> createState() =>
      _UniversityDashboardState();
}

class _UniversityDashboardState
    extends State<UniversityDashboard> {
  final ChallengeStore challengeStore =
      ChallengeStore.instance;

  final TeamStore teamStore =
      TeamStore.instance;

  final ReportAssignmentStore assignmentStore =
      ReportAssignmentStore.instance;

  List<Map<String, dynamic>> _assignments = [];
  bool _loadingAssignments = true;
  String? _assignmentError;

  @override
  void initState() {
    super.initState();

    challengeStore.addListener(_refresh);
    teamStore.addListener(_refresh);
    _loadAssignments();
  }

  @override
  void dispose() {
    challengeStore.removeListener(_refresh);
    teamStore.removeListener(_refresh);

    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAssignments() async {
    try {
      final rows = await assignmentStore.loadAssignmentsForUser('university');
      if (!mounted) return;
      setState(() { _assignments = rows; _loadingAssignments = false; _assignmentError = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loadingAssignments = false; _assignmentError = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _updateAssignment(Map<String, dynamic> assignment, String status) async {
    try {
      await assignmentStore.updateAssignmentStatus(
        assignmentId: (assignment['id'] as num).toInt(),
        reportId: assignment['report_id'] as String,
        newStatus: status,
        updateTitle: status == 'Accepted' ? 'Work Accepted by University' : status == 'In Progress' ? 'Work Started' : 'Solution Submitted',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report updated to $status.')));
      await _loadAssignments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  // ------------------------------------------------------------
  // NAVIGATION
  // ------------------------------------------------------------

  void _openChallenges() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const UniversityChallengesPage(),
      ),
    );
  }

  void _openTeam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const UniversityTeamPage(),
      ),
    );
  }

  void _openChallengeDetails(
    Challenge challenge,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChallengeDetailsPage(
          challenge: challenge,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final challenges =
        challengeStore.assignedChallenges;

    final previewChallenges =
        challenges.take(2).toList();

    return Scaffold(
      backgroundColor:
          UniversityDashboard.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // WELCOME
                    // ------------------------------------------------

                    const Text(
                      'Welcome, Annamacharya Engineering College ✨',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            UniversityDashboard.darkText,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Innovate for a better society',
                      style: TextStyle(
                        color:
                            UniversityDashboard.greyText,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ------------------------------------------------
                    // STATISTICS
                    // ------------------------------------------------

                    _buildStatistics(),

                    const SizedBox(height: 30),

                    // ------------------------------------------------
                    // GOVERNMENT-ASSIGNED REPORTS
                    // ------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Text('Government Assigned Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: UniversityDashboard.darkText))),
                        IconButton(onPressed: _loadAssignments, icon: const Icon(Icons.refresh)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_loadingAssignments)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (_assignmentError != null)
                      Text(_assignmentError!, style: const TextStyle(color: Colors.red))
                    else if (_assignments.isEmpty)
                      Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)), child: const Text('No reports have been assigned to your university yet.', style: TextStyle(color: UniversityDashboard.greyText)))
                    else
                      ..._assignments.map((assignment) {
                        final report = assignment['reports'] as Map<String, dynamic>? ?? {};
                        final status = assignment['status'] as String? ?? 'Assigned';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(report['title'] as String? ?? 'Assigned Report', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: UniversityDashboard.darkText)),
                            const SizedBox(height: 7),
                            Text(report['description'] as String? ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: UniversityDashboard.greyText, height: 1.35)),
                            const SizedBox(height: 8),
                            Text('Location: ${report['location'] ?? 'Unknown'}', style: const TextStyle(fontSize: 12, color: UniversityDashboard.greyText)),
                            if ((assignment['instructions'] as String? ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Instructions: ${assignment['instructions']}', style: const TextStyle(fontSize: 12, color: UniversityDashboard.darkText)),
                            ],
                            const SizedBox(height: 12),
                            Text('Assignment status: $status', style: const TextStyle(fontWeight: FontWeight.w600, color: UniversityDashboard.primaryGreen)),
                            const SizedBox(height: 10),
                            if (status == 'Assigned')
                              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _updateAssignment(assignment, 'Accepted'), child: const Text('Accept Report')))
                            else if (status == 'Accepted')
                              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _updateAssignment(assignment, 'In Progress'), child: const Text('Start Work')))
                            else if (status == 'In Progress')
                              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _updateAssignment(assignment, 'Completed'), child: const Text('Submit Solution')))
                            else
                              const Text('Solution submitted. Waiting for government verification.', style: TextStyle(fontSize: 12, color: UniversityDashboard.greyText)),
                          ]),
                        );
                      }),
                    const SizedBox(height: 20),

                    // ------------------------------------------------
                    // ASSIGNED CHALLENGES HEADING
                    // ------------------------------------------------

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Assigned Challenges',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                              color:
                                  UniversityDashboard
                                      .darkText,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed:
                              _openChallenges,
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color:
                                  UniversityDashboard
                                      .primaryGreen,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ------------------------------------------------
                    // CHALLENGES
                    // ------------------------------------------------

                    if (previewChallenges.isEmpty)
                      _buildNoChallenges()
                    else
                      ...previewChallenges.map(
                        (challenge) =>
                            _ChallengeCard(
                          challenge:
                              challenge,
                          onTap: () =>
                              _openChallengeDetails(
                            challenge,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // ------------------------------------------------
                    // TEAM PREVIEW
                    // ------------------------------------------------

                    _buildTeamPreview(),

                    const SizedBox(height: 15),

                    // ------------------------------------------------
                    // COLLABORATION CARD
                    // ------------------------------------------------

                    _buildCollaborationCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ------------------------------------------------------------
      // BOTTOM NAVIGATION
      // ------------------------------------------------------------

      bottomNavigationBar:
          _buildBottomNavigation(),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color:
                  UniversityDashboard.darkText,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
                color:
                    UniversityDashboard.darkText,
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color:
                  UniversityDashboard.darkText,
            ),
          ),

          const SizedBox(width: 5),

          ProfileButton(
            userName: 'University',
            userEmail: 'university@sahyog.com',
            userRole: 'University',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            number: challengeStore
                .newChallenges
                .toString(),
            title: 'New Challenges',
            icon:
                Icons.assignment_outlined,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _StatCard(
            number: challengeStore
                .inProgressChallenges
                .toString(),
            title: 'In Progress',
            icon:
                Icons.pending_actions_outlined,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _StatCard(
            number: teamStore
                .memberCount
                .toString(),
            title: 'Team Members',
            icon:
                Icons.groups_outlined,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // NO CHALLENGES
  // ------------------------------------------------------------

  Widget _buildNoChallenges() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 42,
            color:
                UniversityDashboard
                    .primaryGreen,
          ),

          SizedBox(height: 10),

          Text(
            'No challenges assigned',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              color:
                  UniversityDashboard
                      .darkText,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'New community challenges will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  UniversityDashboard
                      .greyText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // TEAM PREVIEW
  // ------------------------------------------------------------

  Widget _buildTeamPreview() {
    final members = teamStore.members;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    const BoxDecoration(
                  color:
                      UniversityDashboard
                          .lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color:
                      UniversityDashboard
                          .primaryGreen,
                  size: 27,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Team',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            UniversityDashboard
                                .darkText,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Collaborate with your team members',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            UniversityDashboard
                                .greyText,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: _openTeam,
                child: const Text(
                  'View',
                  style: TextStyle(
                    color:
                        UniversityDashboard
                            .primaryGreen,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (members.isNotEmpty) ...[
            const SizedBox(height: 16),

            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal,
                itemCount:
                    members.length,
                itemBuilder:
                    (context, index) {
                  final member =
                      members[index];

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(right: 8),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          UniversityDashboard
                              .lightGreen,
                      child: Text(
                        member.name
                                .isNotEmpty
                            ? member.name[0]
                                .toUpperCase()
                            : '?',
                        style:
                            const TextStyle(
                          color:
                              UniversityDashboard
                                  .primaryGreen,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // COLLABORATION CARD
  // ------------------------------------------------------------

  Widget _buildCollaborationCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
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
          Container(
            padding:
                const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  UniversityDashboard
                      .lightGreen,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              color:
                  UniversityDashboard
                      .primaryGreen,
              size: 30,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Collaborate with your team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        UniversityDashboard
                            .darkText,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Work together to create innovative solutions for real community problems.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color:
                        UniversityDashboard
                            .greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.06),
            blurRadius: 12,
            offset:
                const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceAround,
          children: [
            _BottomNavItem(
              icon:
                  Icons.home_outlined,
              label: 'Home',
              selected: true,
              onTap: () {},
            ),

            _BottomNavItem(
              icon:
                  Icons.lightbulb_outline,
              label: 'Challenges',
              onTap:
                  _openChallenges,
            ),

            GestureDetector(
              onTap: () {
                _showQuickActions();
              },
              child: Container(
                width: 52,
                height: 52,
                decoration:
                    const BoxDecoration(
                  color:
                      UniversityDashboard
                          .primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            _BottomNavItem(
              icon:
                  Icons.groups_outlined,
              label: 'My Team',
              onTap: _openTeam,
            ),

            _BottomNavItem(
              icon:
                  Icons.more_horiz,
              label: 'More',
              onTap: () {
                _showMoreMenu();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // QUICK ACTIONS
  // ------------------------------------------------------------

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        UniversityDashboard
                            .darkText,
                  ),
                ),

                const SizedBox(height: 18),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor:
                        UniversityDashboard
                            .lightGreen,
                    child: Icon(
                      Icons.lightbulb_outline,
                      color:
                          UniversityDashboard
                              .primaryGreen,
                    ),
                  ),
                  title: const Text(
                    'Browse Challenges',
                  ),
                  subtitle: const Text(
                    'Explore available community challenges',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                    _openChallenges();
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor:
                        UniversityDashboard
                            .lightGreen,
                    child: Icon(
                      Icons.groups_outlined,
                      color:
                          UniversityDashboard
                              .primaryGreen,
                    ),
                  ),
                  title: const Text(
                    'Manage My Team',
                  ),
                  subtitle: const Text(
                    'View and manage team members',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                    _openTeam();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MORE MENU
  // ------------------------------------------------------------

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Padding(
                padding:
                    EdgeInsets.all(20),
                child: Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'More',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          UniversityDashboard
                              .darkText,
                    ),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.person_outline,
                  color:
                      UniversityDashboard
                          .primaryGreen,
                ),
                title: const Text(
                  'University Profile',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(
                        userName: 'University',
                        userEmail: 'university@sahyog.com',
                        userRole: 'University',
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color:
                      UniversityDashboard
                          .primaryGreen,
                ),
                title: const Text(
                  'Settings',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );

                  ScaffoldMessenger
                          .of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Settings coming soon',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;

  const _StatCard({
    required this.number,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                const BoxDecoration(
              color:
                  UniversityDashboard
                      .lightGreen,
              borderRadius:
                  BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Icon(
              icon,
              color:
                  UniversityDashboard
                      .primaryGreen,
              size: 25,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color:
                  UniversityDashboard
                      .darkText,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color:
                  UniversityDashboard
                      .greyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHALLENGE CARD
// ============================================================

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
          const EdgeInsets.all(16),
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
          Text(
            challenge.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color:
                  UniversityDashboard
                      .darkText,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color:
                    UniversityDashboard
                        .greyText,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  challenge.location,
                  style:
                      const TextStyle(
                    color:
                        UniversityDashboard
                            .greyText,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tag(
                challenge.category,
              ),
              _tag(
                '${challenge.priority} Priority',
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    UniversityDashboard
                        .primaryGreen,
                side:
                    const BorderSide(
                  color:
                      UniversityDashboard
                          .primaryGreen,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
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
        color:
            UniversityDashboard
                .lightGreen,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color:
              UniversityDashboard
                  .primaryGreen,
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// BOTTOM NAV ITEM
// ============================================================

class _BottomNavItem
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior:
          HitTestBehavior.opaque,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 5,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected
                  ? UniversityDashboard
                      .primaryGreen
                  : UniversityDashboard
                      .greyText,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? UniversityDashboard
                        .primaryGreen
                    : UniversityDashboard
                        .greyText,
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}