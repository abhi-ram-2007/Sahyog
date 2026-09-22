import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report.dart';
import '../services/report_store.dart';

class ReportDetailsPage extends StatefulWidget {
  final Report report;

  const ReportDetailsPage({
    super.key,
    required this.report,
  });

  @override
  State<ReportDetailsPage> createState() =>
      _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  final ReportStore store = ReportStore.instance;

  late Report report;

  bool isLoadingLatestReport = true;

  @override
  void initState() {
    super.initState();

    // Initially show the report that was passed to this page.
    report = widget.report;

    // Then fetch the latest version from Supabase.
    _loadLatestReport();
  }

  // ============================================================
  // LOAD LATEST REPORT FROM SUPABASE
  // ============================================================

  Future<void> _loadLatestReport() async {
    final Report? latestReport =
        await store.loadReportById(widget.report.id);

    if (!mounted) return;

    if (latestReport != null) {
      setState(() {
        report = latestReport;
      });
    }

    setState(() {
      isLoadingLatestReport = false;
    });
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
          'Report Details',
          style: TextStyle(
            color: Color(0xFF202735),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadLatestReport,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // ----------------------------------------------------
            // MAIN REPORT CARD
            // ----------------------------------------------------

            _buildMainCard(),

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // REPORT INFORMATION
            // ----------------------------------------------------

            _buildInformationCard(),

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // REPORT IMAGES
            // ----------------------------------------------------

            _buildImagesCard(),

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // REPORT TIMELINE
            // ----------------------------------------------------

            _buildTimelineCard(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN REPORT CARD
  // ============================================================

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF087A40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: Colors.white24,
                child: Icon(
                  report.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  report.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            report.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _statusChip(report.status),

              const SizedBox(width: 8),

              _priorityChip(report.priority),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Color(0xFF087A40),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // PRIORITY CHIP
  // ============================================================

  Widget _priorityChip(String priority) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$priority Priority',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // REPORT INFORMATION
  // ============================================================

  Widget _buildInformationCard() {
    return _SectionCard(
      title: 'Report Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.tag,
            title: 'Report ID',
            value: report.id,
          ),

          _InfoRow(
            icon: Icons.category_outlined,
            title: 'Category',
            value: report.category,
          ),

          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: report.location,
          ),

          _InfoRow(
            icon: Icons.account_balance_outlined,
            title: 'Department',
            value: report.department,
          ),

          _InfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Submitted',
            value: _formatDate(report.submittedAt),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REPORT IMAGES
  // ============================================================

  Widget _buildImagesCard() {
    return FutureBuilder<List<String>>(
      future: _getSignedImageUrls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return _SectionCard(
            title: 'Report Photos',
            icon: Icons.photo_library_outlined,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return _SectionCard(
            title: 'Report Photos',
            icon: Icons.photo_library_outlined,
            child: Text(
              'Unable to load report photos.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }

        final List<String> imageUrls =
            snapshot.data ?? [];

        if (imageUrls.isEmpty) {
          return const SizedBox.shrink();
        }

        return _SectionCard(
          title: 'Report Photos',
          icon: Icons.photo_library_outlined,
          child: SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showFullImage(
                      context,
                      imageUrls[index],
                    );
                  },
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: Image.network(
                      imageUrls[index],
                      width: 190,
                      height: 190,
                      fit: BoxFit.cover,

                      loadingBuilder:
                          (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Container(
                          width: 190,
                          height: 190,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      },

                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          width: 190,
                          height: 190,
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color: Colors.grey.shade500,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GET SIGNED IMAGE URLS
  // ============================================================

  Future<List<String>> _getSignedImageUrls() async {
    final SupabaseClient supabase =
        Supabase.instance.client;

    try {
      final dynamic response = await supabase
          .from('reports')
          .select('image_urls')
          .eq('id', report.id)
          .maybeSingle();

      if (response == null) {
        return [];
      }

      final dynamic imageUrlsValue =
          response['image_urls'];

      if (imageUrlsValue is! List) {
        return [];
      }

      final List<String> paths = imageUrlsValue
          .whereType<String>()
          .where(
            (path) => path.trim().isNotEmpty,
          )
          .toList();

      if (paths.isEmpty) {
        return [];
      }

      final List<String> signedUrls = [];

      for (final String path in paths) {
        try {
          final String signedUrl =
              await supabase.storage
                  .from('report-images')
                  .createSignedUrl(
                    path,
                    60 * 60,
                  );

          signedUrls.add(signedUrl);
        } catch (e) {
          debugPrint(
            'Unable to create signed URL for $path: $e',
          );
        }
      }

      return signedUrls;
    } catch (e) {
      debugPrint(
        'Unable to load report images: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // FULL IMAGE VIEW
  // ============================================================

  void _showFullImage(
    BuildContext context,
    String imageUrl,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // TIMELINE
  // ============================================================

  Widget _buildTimelineCard() {
    return _SectionCard(
      title: 'Report Timeline',
      icon: Icons.timeline,
      child: Column(
        children: List.generate(
          report.updates.length,
          (index) {
            final ReportUpdate update =
                report.updates[index];

            return _TimelineItem(
              update: update,
              isLast:
                  index == report.updates.length - 1,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
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
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF087A40),
              ),

              const SizedBox(width: 8),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202735),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// INFORMATION ROW
// ================================================================

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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
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

// ================================================================
// TIMELINE ITEM
// ================================================================

class _TimelineItem extends StatelessWidget {
  final ReportUpdate update;
  final bool isLast;

  const _TimelineItem({
    required this.update,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: update.completed
                        ? const Color(0xFF087A40)
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF087A40),
                      width: 2,
                    ),
                  ),
                  child: update.completed
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: update.completed
                          ? const Color(0xFF087A40)
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    update.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: update.completed
                          ? const Color(0xFF202735)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    update.description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatDate(update.date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}