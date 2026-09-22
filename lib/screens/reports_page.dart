import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/report_store.dart';
import 'report_details_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportStore store = ReportStore.instance;

  String selectedFilter = 'All';
  String searchQuery = '';

  final List<String> filters = [
    'All',
    'Pending',
    'Assigned',
    'Work in Progress',
    'Solution Submitted',
    'Resolved',
  ];

  @override
  void initState() {
    super.initState();
    store.addListener(_refresh);
    store.loadReports();
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

  List<Report> get filteredReports {
    return store.reports.where((report) {
      final matchesFilter =
          selectedFilter == 'All' || report.status == selectedFilter;

      final query = searchQuery.toLowerCase().trim();

      final matchesSearch =
          query.isEmpty ||
          report.title.toLowerCase().contains(query) ||
          report.location.toLowerCase().contains(query) ||
          report.category.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countFor(String status) {
    if (status == 'All') {
      return store.reports.length;
    }

    return store.reports
        .where((report) => report.status == status)
        .length;
  }

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
          'My Reports',
          style: TextStyle(
            color: Color(0xFF202735),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildHeader(),

          _buildSearchBar(),

          _buildFilters(),

          const SizedBox(height: 8),

          Expanded(
            child: filteredReports.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      30,
                    ),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];

                      return _ReportHistoryCard(
                        report: report,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportDetailsPage(
                                report: report,
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Track all the problems you have reported.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search your reports...',
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
          ),
          filled: true,
          fillColor: const Color(0xFFF6F8F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 62,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter == selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF087A40)
                    : const Color(0xFFE7F5ED),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                '$filter (${_countFor(filter)})',
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : const Color(0xFF087A40),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE7F5ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 40,
                color: Color(0xFF087A40),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Reports Found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202735),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              searchQuery.isNotEmpty
                  ? 'Try searching with a different keyword.'
                  : 'You have not submitted any reports yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHistoryCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const _ReportHistoryCard({
    required this.report,
    required this.onTap,
  });

  Color get statusBackground {
    switch (report.status) {
    case 'Resolved':
      return const Color(0xFFE7F5ED);

    case 'Work in Progress':
    case 'Solution Submitted':
      return const Color(0xFFFFF3CD);

    case 'Assigned':
      return const Color(0xFFE8EEF9);

    case 'Pending':
      return const Color(0xFFE8EEF9);

    default:
      return Colors.grey.shade100;
  }
  }

  Color get statusColor {
  switch (report.status) {
    case 'Resolved':
      return const Color(0xFF087A40);

    case 'Work in Progress':
    case 'Solution Submitted':
      return Colors.orange.shade800;

    case 'Assigned':
      return Colors.blue.shade700;

    case 'Pending':
      return Colors.blue.shade700;

    default:
      return Colors.grey.shade700;
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE7F5ED),
              child: Icon(
                report.icon,
                color: const Color(0xFF087A40),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202735),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          report.location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'ID: ${report.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}