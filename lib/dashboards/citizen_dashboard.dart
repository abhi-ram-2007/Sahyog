import 'package:flutter/material.dart';

import '../services/report_store.dart';
import '../services/auth_service.dart';

import '../screens/report_details_page.dart';
import '../screens/report_issue_page.dart';
import '../screens/reports_page.dart';
import '../screens/landing_page.dart';

import '../widgets/profile_button.dart';

class CitizenDashboard extends StatefulWidget {
  const CitizenDashboard({super.key});

  static const Color primaryGreen = Color(0xFF087A40);
  static const Color lightGreen = Color(0xFFE7F5ED);
  static const Color background = Color(0xFFF6F8F7);
  static const Color darkText = Color(0xFF202735);
  static const Color greyText = Color(0xFF6B7280);

  @override
  State<CitizenDashboard> createState() =>
      _CitizenDashboardState();
}

class _CitizenDashboardState extends State<CitizenDashboard> {
  final ReportStore reportStore = ReportStore.instance;
  final AuthService _authService = AuthService();

  String userName = 'Citizen';
  String userEmail = '';
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();

    reportStore.addListener(_onReportsChanged);

    _loadProfile();
    reportStore.loadReports();
  }

  @override
  void dispose() {
    reportStore.removeListener(_onReportsChanged);
    super.dispose();
  }

  // ============================================================
  // LOAD USER PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getProfile();

      if (!mounted) return;

      setState(() {
        userName =
            (profile['full_name'] as String?)?.trim().isNotEmpty == true
                ? profile['full_name'] as String
                : 'Citizen';

        userEmail =
            (profile['email'] as String?) ?? '';

        isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  // ============================================================
  // REPORTS
  // ============================================================

  void _onReportsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // OPEN ALL REPORTS
  // ============================================================

  Future<void> _openReports() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportsPage(),
      ),
    );

    if (!mounted) return;

    // Refresh dashboard with latest Supabase data
    await reportStore.refresh();
  }

  // ============================================================
  // OPEN REPORT ISSUE
  // ============================================================

  Future<void> _openReportIssue() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportIssuePage(),
      ),
    );

    if (!mounted) return;

    // Refresh after creating a new report
    await reportStore.refresh();
  }

  // ============================================================
  // OPEN REPORT DETAILS
  // ============================================================

  Future<void> _openReportDetails(dynamic report) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsPage(
          report: report,
        ),
      ),
    );

    if (!mounted) return;

    // Refresh after returning from report details
    await reportStore.refresh();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LandingPage(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'Unable to logout. Please try again.',
      );
    }
  }

  // ============================================================
  // PROFILE POPUP
  // ============================================================

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // HANDLE
                // ==================================================

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // PROFILE ICON
                // ==================================================

                Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(
                    color: CitizenDashboard.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _getInitial(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // NAME
                // ==================================================

                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CitizenDashboard.darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                // ==================================================
                // EMAIL
                // ==================================================

                Text(
                  userEmail.isEmpty
                      ? 'Email not available'
                      : userEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CitizenDashboard.greyText,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // ACCOUNT TYPE
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        CitizenDashboard.lightGreen,
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color:
                            CitizenDashboard.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Account Type',
                          style: TextStyle(
                            color:
                                CitizenDashboard.darkText,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Citizen',
                          style: TextStyle(
                            color:
                                CitizenDashboard.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // PROFILE DETAILS
                // ==================================================

                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      color:
                          CitizenDashboard.darkText,
                    ),
                  ),
                  title: const Text(
                    'Profile Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color:
                          CitizenDashboard.darkText,
                    ),
                  ),
                  subtitle: const Text(
                    'View your account information',
                    style: TextStyle(
                      color:
                          CitizenDashboard.greyText,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color:
                        CitizenDashboard.greyText,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showProfileDetails();
                  },
                ),

                const SizedBox(height: 8),

                // ==================================================
                // LOGOUT
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmLogout();
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(
                        color: Colors.red.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE DETAILS
  // ============================================================

  void _showProfileDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Profile Details',
            style: TextStyle(
              color: CitizenDashboard.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _profileDetail(
                icon: Icons.person_outline,
                title: 'Full Name',
                value: userName,
              ),
              const SizedBox(height: 18),
              _profileDetail(
                icon: Icons.email_outlined,
                title: 'Email',
                value: userEmail.isEmpty
                    ? 'Not available'
                    : userEmail,
              ),
              const SizedBox(height: 18),
              _profileDetail(
                icon: Icons.badge_outlined,
                title: 'Account Type',
                value: 'Citizen',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(
                  color:
                      CitizenDashboard.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _profileDetail({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: CitizenDashboard.primaryGreen,
          size: 23,
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
                  color:
                      CitizenDashboard.greyText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color:
                      CitizenDashboard.darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONFIRM LOGOUT
  // ============================================================

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: CitizenDashboard.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from your Sahyog account?',
            style: TextStyle(
              color: CitizenDashboard.greyText,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color:
                      CitizenDashboard.greyText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    CitizenDashboard.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // PROFILE INITIAL
  // ============================================================

  String _getInitial() {
    if (userName.trim().isEmpty) {
      return 'C';
    }

    return userName
        .trim()
        .substring(0, 1)
        .toUpperCase();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CitizenDashboard.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ==================================================
                    // WELCOME
                    // ==================================================

                    Text(
                      isLoadingProfile
                          ? 'Welcome 👋'
                          : 'Welcome, $userName 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            CitizenDashboard.darkText,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Report, Track, Improve Your Community',
                      style: TextStyle(
                        color:
                            CitizenDashboard.greyText,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _buildReportProblemCard(context),

                    const SizedBox(height: 28),

                    _buildMyReportsSection(),

                    const SizedBox(height: 15),

                    _buildCommunityUpdates(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar:
          _buildBottomNavigation(context),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
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
            constraints: const BoxConstraints(
              minWidth: 42,
              minHeight: 42,
            ),
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: CitizenDashboard.darkText,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Citizen Dashboard',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color:
                    CitizenDashboard.darkText,
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 28,
              color:
                  CitizenDashboard.darkText,
            ),
          ),

          const SizedBox(width: 5),

          // ========================================================
          // PROFILE BUTTON
          // ========================================================

          ProfileButton(
            userName: userName,
            userEmail: userEmail,
            userRole: 'Citizen',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT PROBLEM CARD
  // ============================================================

  Widget _buildReportProblemCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            CitizenDashboard.primaryGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.campaign_outlined,
            color: Colors.white,
            size: 32,
          ),

          const SizedBox(height: 12),

          const Text(
            'Have a problem in your community?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Report it and help create a better community.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _openReportIssue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
                  CitizenDashboard.primaryGreen,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Report a Problem',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MY REPORTS
  // ============================================================

  Widget _buildMyReportsSection() {
    final latestReports =
        reportStore.latestReports;

    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    CitizenDashboard.darkText,
              ),
            ),

            TextButton(
              onPressed: _openReports,
              child: const Text(
                'View All',
                style: TextStyle(
                  color:
                      CitizenDashboard.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (latestReports.isEmpty)
          _buildNoReports()
        else
          ...latestReports.map(
            (report) => _ReportCard(
              report: report,
              onTap: () =>
                  _openReportDetails(report),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // NO REPORTS
  // ============================================================

  Widget _buildNoReports() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 40,
            color:
                CitizenDashboard.primaryGreen,
          ),

          SizedBox(height: 10),

          Text(
            'No reports yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  CitizenDashboard.darkText,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Your submitted reports will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  CitizenDashboard.greyText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMUNITY UPDATES
  // ============================================================

  Widget _buildCommunityUpdates() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Community Updates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                CitizenDashboard.darkText,
          ),
        ),

        const SizedBox(height: 14),

        _UpdateCard(
          title: 'New solution proposed',
          description:
              'A university team proposed a solution for drainage blockage.',
          icon: Icons.lightbulb_outline,
        ),

        _UpdateCard(
          title: 'Problem resolved',
          description:
              'Pothole repair at Ward 3 has been completed.',
          icon: Icons.check_circle_outline,
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: true,
              onTap: () {},
            ),

            _BottomNavItem(
              icon: Icons.assignment_outlined,
              label: 'Reports',
              onTap: _openReports,
            ),

            GestureDetector(
              onTap: _openReportIssue,
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color:
                      CitizenDashboard.primaryGreen,
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
                  Icons.notifications_none,
              label: 'Updates',
              onTap: () {},
            ),

            _BottomNavItem(
              icon: Icons.more_horiz,
              label: 'More',
              onTap: _showProfileMenu,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// REPORT CARD
// ==================================================================

class _ReportCard extends StatelessWidget {
  final dynamic report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool resolved =
        report.status == 'Resolved';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  CitizenDashboard.lightGreen,
              child: Icon(
                report.icon,
                color:
                    CitizenDashboard.primaryGreen,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                      color:
                          CitizenDashboard.darkText,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    report.location,
                    style: const TextStyle(
                      color:
                          CitizenDashboard.greyText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              constraints:
                  const BoxConstraints(
                maxWidth: 115,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: resolved
                    ? CitizenDashboard.lightGreen
                    : const Color(0xFFFFF3CD),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                report.status,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: resolved
                      ? CitizenDashboard
                          .primaryGreen
                      : Colors.orange.shade800,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// UPDATE CARD
// ==================================================================

class _UpdateCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _UpdateCard({
    required this.title,
    required this.description,
    required this.icon,
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
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  CitizenDashboard.lightGreen,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color:
                  CitizenDashboard.primaryGreen,
            ),
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
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 15,
                    color:
                        CitizenDashboard.darkText,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    color:
                        CitizenDashboard.greyText,
                    fontSize: 13,
                    height: 1.4,
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

// ==================================================================
// BOTTOM NAV ITEM
// ==================================================================

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
        padding:
            const EdgeInsets.symmetric(
          horizontal: 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected
                  ? CitizenDashboard
                      .primaryGreen
                  : CitizenDashboard.greyText,
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? CitizenDashboard
                        .primaryGreen
                    : CitizenDashboard.greyText,
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