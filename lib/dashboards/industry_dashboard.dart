import 'package:flutter/material.dart';

import '../screens/profile_page.dart';
import '../widgets/profile_button.dart';
import '../services/report_assignment_store.dart';

class IndustryDashboard extends StatefulWidget {
  const IndustryDashboard({super.key});

  static const Color primaryGreen = Color(0xFF087A40);
  static const Color lightGreen = Color(0xFFE7F5ED);
  static const Color background = Color(0xFFF6F8F7);
  static const Color darkText = Color(0xFF202735);
  static const Color greyText = Color(0xFF6B7280);

  @override
  State<IndustryDashboard> createState() => _IndustryDashboardState();
}

class _IndustryDashboardState extends State<IndustryDashboard> {
  final ReportAssignmentStore _assignmentStore = ReportAssignmentStore.instance;
  List<Map<String, dynamic>> _assignments = [];
  bool _loadingAssignments = true;
  String? _assignmentError;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final rows = await _assignmentStore.loadAssignmentsForUser('industry');
      if (!mounted) return;
      setState(() { _assignments = rows; _loadingAssignments = false; _assignmentError = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loadingAssignments = false; _assignmentError = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _updateAssignment(Map<String, dynamic> assignment, String status) async {
    try {
      await _assignmentStore.updateAssignmentStatus(
        assignmentId: (assignment['id'] as num).toInt(),
        reportId: assignment['report_id'] as String,
        newStatus: status,
        updateTitle: status == 'Accepted' ? 'Work Accepted by Industry' : status == 'In Progress' ? 'Work Started' : 'Solution Submitted',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report updated to $status.')));
      await _loadAssignments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IndustryDashboard.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      'Welcome, TechBuild Solutions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: IndustryDashboard.darkText,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Collaborate, Innovate, Create Impact',
                      style: TextStyle(
                        color: IndustryDashboard.greyText,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Statistics
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            number: '6',
                            title: 'Opportunities',
                            icon: Icons.lightbulb_outline,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _StatCard(
                            number: '4',
                            title: 'Active Projects',
                            icon: Icons.work_outline,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _StatCard(
                            number: '2',
                            title: 'Partner Requests',
                            icon: Icons.people_outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Government-assigned reports
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Government Assigned Reports', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: IndustryDashboard.darkText)),
                        IconButton(onPressed: _loadAssignments, icon: const Icon(Icons.refresh)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_loadingAssignments)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (_assignmentError != null)
                      Text(_assignmentError!, style: const TextStyle(color: Colors.red))
                    else if (_assignments.isEmpty)
                      Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)), child: const Text('No reports have been assigned to your industry yet.', style: TextStyle(color: IndustryDashboard.greyText)))
                    else
                      ..._assignments.map((assignment) {
                        final report = assignment['reports'] as Map<String, dynamic>? ?? {};
                        final status = assignment['status'] as String? ?? 'Assigned';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(report['title'] as String? ?? 'Assigned Report', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: IndustryDashboard.darkText)),
                            const SizedBox(height: 7),
                            Text(report['description'] as String? ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: IndustryDashboard.greyText, height: 1.35)),
                            const SizedBox(height: 8),
                            Text('Location: ${report['location'] ?? 'Unknown'}', style: const TextStyle(fontSize: 12, color: IndustryDashboard.greyText)),
                            if ((assignment['instructions'] as String? ?? '').trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Instructions: ${assignment['instructions']}', style: const TextStyle(fontSize: 12, color: IndustryDashboard.darkText)),
                            ],
                            const SizedBox(height: 12),
                            Text('Assignment status: $status', style: const TextStyle(fontWeight: FontWeight.w600, color: IndustryDashboard.primaryGreen)),
                            const SizedBox(height: 10),
                            if (status == 'Assigned')
                              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _updateAssignment(assignment, 'Accepted'), child: const Text('Accept Report')))
                            else if (status == 'Accepted')
                              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _updateAssignment(assignment, 'In Progress'), child: const Text('Start Work')))
                            else if (status == 'In Progress')
                              SizedBox(width: double.infinity, child: FilledButton(onPressed: () => _updateAssignment(assignment, 'Completed'), child: const Text('Submit Solution')))
                            else
                              const Text('Solution submitted. Waiting for government verification.', style: TextStyle(fontSize: 12, color: IndustryDashboard.greyText)),
                          ]),
                        );
                      }),
                    const SizedBox(height: 20),

                    // Opportunities heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Recommended Opportunities',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: IndustryDashboard.darkText,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: IndustryDashboard.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Opportunity 1
                    _OpportunityCard(
                      title: 'Smart Drain Monitoring System',
                      location: 'Ward 12, Rajampet',
                      tags: const [
                        'IoT',
                        'Sanitation',
                        'University Proposal',
                      ],
                      description:
                          'IoT-based sensors to detect drainage blockages and provide real-time alerts.',
                    ),

                    // Opportunity 2
                    _OpportunityCard(
                      title: 'Low-cost Water Purification Unit',
                      location: 'Ananthapur',
                      tags: const [
                        'Hardware',
                        'Healthcare',
                      ],
                      description:
                          'Affordable water purification solution for communities with limited access to clean water.',
                    ),

                    const SizedBox(height: 5),

                    // Collaboration section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.handshake_outlined,
                            color: IndustryDashboard.primaryGreen,
                            size: 30,
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Build solutions together',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: IndustryDashboard.darkText,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Partner with universities and government teams.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: IndustryDashboard.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: IndustryDashboard.darkText,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Industry Dashboard',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: IndustryDashboard.darkText,
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: IndustryDashboard.darkText,
            ),
          ),

          const SizedBox(width: 5),

          ProfileButton(
            userName: 'Industry',
            userEmail: 'industry@sahyog.com',
            userRole: 'Industry',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: true,
              onTap: () {},
            ),
            _BottomNavItem(
              icon: Icons.lightbulb_outline,
              label: 'Opportunities',
              onTap: () {},
            ),

            GestureDetector(
              onTap: () {},
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: IndustryDashboard.primaryGreen,
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
              icon: Icons.work_outline,
              label: 'Projects',
              onTap: () {},
            ),
            _BottomNavItem(
              icon: Icons.more_horiz,
              label: 'More',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(
                      userName: 'Industry',
                      userEmail: 'industry@sahyog.com',
                      userRole: 'Industry',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: IndustryDashboard.primaryGreen,
            size: 24,
          ),

          const SizedBox(height: 8),

          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: IndustryDashboard.darkText,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: IndustryDashboard.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// OPPORTUNITY CARD
// ============================================================

class _OpportunityCard extends StatelessWidget {
  final String title;
  final String location;
  final List<String> tags;
  final String description;

  const _OpportunityCard({
    required this.title,
    required this.location,
    required this.tags,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: IndustryDashboard.darkText,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: IndustryDashboard.primaryGreen,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: IndustryDashboard.greyText,
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
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: IndustryDashboard.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: IndustryDashboard.primaryGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          Text(
            description,
            style: const TextStyle(
              color: IndustryDashboard.greyText,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: IndustryDashboard.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View Proposal',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM NAV ITEM
// ============================================================

class _BottomNavItem extends StatelessWidget {
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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected
                  ? IndustryDashboard.primaryGreen
                  : IndustryDashboard.greyText,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? IndustryDashboard.primaryGreen
                    : IndustryDashboard.greyText,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}