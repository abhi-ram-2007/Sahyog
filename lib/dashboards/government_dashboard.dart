import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/profile_button.dart';
import '../screens/profile_page.dart';
import '../services/report_assignment_store.dart';

class GovernmentDashboard extends StatefulWidget {
  const GovernmentDashboard({super.key});

  static const Color primaryGreen = Color(0xFF087A40);
  static const Color lightGreen = Color(0xFFE5F5EC);
  static const Color background = Color(0xFFF5F7F6);
  static const Color darkText = Color(0xFF202735);
  static const Color greyText = Color(0xFF6B7280);

  @override
  State<GovernmentDashboard> createState() => _GovernmentDashboardState();
}

class _GovernmentDashboardState extends State<GovernmentDashboard> {
  final ReportAssignmentStore _store = ReportAssignmentStore.instance;
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _industries = [];
  List<Map<String, dynamic>> _universities = [];
  bool _loading = true;
  String? _error;
  String _userName = 'Government';
  String _userEmail = 'government@sahyog.com';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      debugPrint('========================================');
      debugPrint('AUTH USER ID: ${user?.id}');
      debugPrint('AUTH USER EMAIL: ${user?.email}');
      debugPrint('========================================');
      if (user != null) {
        final profile = await supabase.from('profiles').select('full_name,email').eq('id', user.id).maybeSingle();
        if (profile != null) {
          final name = (profile['full_name'] as String?)?.trim();
          _userName = name == null || name.isEmpty ? 'Government' : name;
          _userEmail = (profile['email'] as String?) ?? user.email ?? _userEmail;
        }
      }
      final results = await Future.wait([
        _store.loadGovernmentReports(),
        _store.loadOrganizations('industry'),
        _store.loadOrganizations('university'),
      ]);
      if (!mounted) return;
      setState(() {
        _reports = results[0];
        _industries = results[1];
        _universities = results[2];
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _assignReport(Map<String, dynamic> report) async {
    String role = 'industry';
    String? selectedId;
    final instructions = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) {
            final people = role == 'industry' ? _industries : _universities;
            return AlertDialog(
              title: const Text('Assign Report'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Align(alignment: Alignment.centerLeft, child: Text(report['title'] ?? 'Report', style: const TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: 'Assign to', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'industry', child: Text('Industry')),
                      DropdownMenuItem(value: 'university', child: Text('University')),
                    ],
                    onChanged: (v) { if (v != null) setDialogState(() { role = v; selectedId = null; }); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedId,
                    decoration: InputDecoration(labelText: role == 'industry' ? 'Select Industry' : 'Select University', border: const OutlineInputBorder()),
                    items: people.map((person) {
                      final name = (person['full_name'] as String?)?.trim();
                      final email = person['email'] as String? ?? '';
                      return DropdownMenuItem<String>(value: person['id'] as String, child: Text(name == null || name.isEmpty ? email : name, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: instructions, maxLines: 3, decoration: const InputDecoration(labelText: 'Instructions', border: OutlineInputBorder())),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                FilledButton(
                  onPressed: selectedId == null ? null : () async {
                    try {
                      await _store.assignReport(reportId: report['id'] as String, assignedTo: selectedId!, assignedRole: role, instructions: instructions.text);
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report assigned successfully.')));
                      await _loadDashboard();
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
                    }
                  },
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        ),
      );
    } finally {
      instructions.dispose();
    }
  }

  Future<void> _resolveReport(String reportId) async {
    try {
      await _store.resolveReport(reportId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report resolved.')));
      await _loadDashboard();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'work in progress': return Colors.orange;
      case 'assigned': return Colors.blue;
      case 'solution submitted': return Colors.purple;
      default: return GovernmentDashboard.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GovernmentDashboard.background,

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

                    const SizedBox(height: 10),
                    Text(
                      'Welcome, $_userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: GovernmentDashboard.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Monitor, Facilitate, Create Impact',
                      style: TextStyle(fontSize: 14, color: GovernmentDashboard.greyText),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: _StatCard(number: _reports.length.toString(), title: 'Total Reports', icon: Icons.assignment_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(number: _reports.where((r) => ['assigned', 'work in progress', 'solution submitted'].contains((r['status'] ?? '').toString().toLowerCase())).length.toString(), title: 'In Progress', icon: Icons.pending_actions_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(number: _reports.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'resolved').length.toString(), title: 'Resolved', icon: Icons.check_circle_outline)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Citizen Reports', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: GovernmentDashboard.darkText)),
                        IconButton(onPressed: _loadDashboard, icon: const Icon(Icons.refresh)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                    else if (_error != null)
                      _MessageCard(message: _error!, onRetry: _loadDashboard)
                    else if (_reports.isEmpty)
                      const _MessageCard(message: 'No citizen reports have been submitted yet.')
                    else
                      ..._reports.map((report) {
                        final status = report['status'] as String? ?? 'Pending';
                        final color = _statusColor(status);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Text(report['title'] as String? ?? 'Untitled Report', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GovernmentDashboard.darkText))),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
                            ]),
                            const SizedBox(height: 8),
                            Text(report['description'] as String? ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: GovernmentDashboard.greyText, height: 1.35)),
                            const SizedBox(height: 8),
                            Text('${report['location'] ?? 'Unknown location'} • ${report['category'] ?? 'Other'}', style: const TextStyle(fontSize: 12, color: GovernmentDashboard.greyText)),
                            const SizedBox(height: 12),
                            if (status.toLowerCase() == 'solution submitted')
                              SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _resolveReport(report['id'] as String), icon: const Icon(Icons.verified_outlined), label: const Text('Verify & Resolve'), style: FilledButton.styleFrom(backgroundColor: GovernmentDashboard.primaryGreen)))
                            else if (status.toLowerCase() != 'resolved')
                              SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _assignReport(report), icon: const Icon(Icons.group_add_outlined), label: const Text('Assign to Industry / University'), style: OutlinedButton.styleFrom(foregroundColor: GovernmentDashboard.primaryGreen, side: const BorderSide(color: GovernmentDashboard.primaryGreen)))),
                          ]),
                        );
                      }),
                    const SizedBox(height: 10),
                    // Government action section
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
                            Icons.admin_panel_settings_outlined,
                            color: GovernmentDashboard.primaryGreen,
                            size: 30,
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Government Action Center',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: GovernmentDashboard.darkText,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Monitor challenges, solutions and implementation.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: GovernmentDashboard.greyText,
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
              color: GovernmentDashboard.darkText,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Government Dashboard',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: GovernmentDashboard.darkText,
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color: GovernmentDashboard.darkText,
            ),
          ),

          const SizedBox(width: 5),

          ProfileButton(
            userName: 'Government',
            userEmail: 'government@sahyog.com',
            userRole: 'Government',
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
              icon: Icons.assignment_outlined,
              label: 'Challenges',
              onTap: () {},
            ),

            GestureDetector(
              onTap: () {},
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: GovernmentDashboard.primaryGreen,
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
              icon: Icons.analytics_outlined,
              label: 'Reports',
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
                      userName: 'Government',
                      userEmail: 'government@sahyog.com',
                      userRole: 'Government',
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
            color: GovernmentDashboard.primaryGreen,
            size: 25,
          ),

          const SizedBox(height: 8),

          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: GovernmentDashboard.darkText,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: GovernmentDashboard.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACTIVITY CARD
// ============================================================



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
                  ? GovernmentDashboard.primaryGreen
                  : GovernmentDashboard.greyText,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? GovernmentDashboard.primaryGreen
                    : GovernmentDashboard.greyText,
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
class _MessageCard extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _MessageCard({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: GovernmentDashboard.primaryGreen),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: GovernmentDashboard.greyText)),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
