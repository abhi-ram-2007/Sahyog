import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report.dart';

class ReportStore extends ChangeNotifier {
  ReportStore._();

  static final ReportStore instance = ReportStore._();

  final SupabaseClient _supabase = Supabase.instance.client;

  final List<Report> _reports = [];

  bool _isLoading = false;
  bool _hasLoaded = false;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Report> get reports => List.unmodifiable(_reports);

  bool get isLoading => _isLoading;

  bool get hasLoaded => _hasLoaded;

  List<Report> get latestReports {
    final sorted = [..._reports];

    sorted.sort(
      (a, b) => b.submittedAt.compareTo(a.submittedAt),
    );

    return sorted.take(3).toList();
  }

  // ============================================================
  // LOAD REPORTS FROM SUPABASE
  // ============================================================

  Future<void> loadReports() async {
    if (_isLoading) return;

    final user = _supabase.auth.currentUser;

    if (user == null) {
      _reports.clear();
      _hasLoaded = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> response = await _supabase
          .from('reports')
          .select('''
            id,
            user_id,
            title,
            description,
            location,
            category,
            status,
            priority,
            department,
            submitted_at,
            image_urls,
            report_updates (
              id,
              title,
              description,
              date,
              completed
            )
          ''')
          .eq('user_id', user.id)
          .order('submitted_at', ascending: false);

      final List<Report> loadedReports = [];

      for (final item in response) {
        try {
          loadedReports.add(
            _reportFromSupabase(
              Map<String, dynamic>.from(item),
            ),
          );
        } catch (e) {
          debugPrint(
            'Unable to convert report: $e',
          );
        }
      }

      _reports
        ..clear()
        ..addAll(loadedReports);

      _hasLoaded = true;
    } catch (e) {
      debugPrint(
        'Unable to load reports from Supabase: $e',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CONVERT SUPABASE REPORT → REPORT MODEL
  // ============================================================

  Report _reportFromSupabase(
    Map<String, dynamic> data,
  ) {
    final String category =
        (data['category'] as String?) ?? 'Other';

    final String status =
        (data['status'] as String?) ?? 'Pending';

    final String? imagePath =
        _firstImageUrl(data['image_urls']);

    final List<ReportUpdate> updates = [];

    final dynamic updatesData =
        data['report_updates'];

    // ------------------------------------------------------------
    // CHECK WHETHER A REAL INDUSTRY / UNIVERSITY ASSIGNMENT
    // EXISTS IN THE TIMELINE
    // ------------------------------------------------------------

    bool hasIndustryAssignment = false;
    bool hasUniversityAssignment = false;

    if (updatesData is List) {
      for (final update in updatesData) {
        if (update is! Map) continue;

        final String title =
            (update['title'] as String?) ?? '';

        if (title.toLowerCase() ==
            'assigned to industry') {
          hasIndustryAssignment = true;
        }

        if (title.toLowerCase() ==
            'assigned to university') {
          hasUniversityAssignment = true;
        }
      }

      // ----------------------------------------------------------
      // BUILD TIMELINE
      //
      // We keep only ONE timeline item for each title.
      // This prevents:
      //
      // Work Started
      // Work Started
      // Work Started
      //
      // from appearing multiple times.
      // ----------------------------------------------------------

      final Map<String, Map<String, dynamic>>
          uniqueUpdates = {};

      for (final update in updatesData) {
        if (update is! Map) continue;

        final String title =
            (update['title'] as String?) ?? '';

        final String description =
            (update['description'] as String?) ?? '';

        // --------------------------------------------------------
        // REMOVE OLD PLACEHOLDER
        // --------------------------------------------------------

        if (title.toLowerCase() ==
            'assigned to department') {
          if (hasIndustryAssignment ||
              hasUniversityAssignment) {
            continue;
          }
        }

        final String uniqueKey =
            title.trim().toLowerCase();

        if (uniqueKey.isEmpty) {
          continue;
        }

        final Map<String, dynamic> currentUpdate =
            Map<String, dynamic>.from(update);

        // --------------------------------------------------------
        // DUPLICATE PROTECTION
        //
        // If the same timeline title already exists,
        // keep the newest record.
        // --------------------------------------------------------

        if (!uniqueUpdates.containsKey(uniqueKey)) {
          uniqueUpdates[uniqueKey] = currentUpdate;
        } else {
          final DateTime existingDate =
              _parseDate(
            uniqueUpdates[uniqueKey]!['date'],
          );

          final DateTime currentDate =
              _parseDate(
            currentUpdate['date'],
          );

          if (currentDate.isAfter(existingDate)) {
            uniqueUpdates[uniqueKey] =
                currentUpdate;
          }
        }

        // Prevent unused-variable warning for clarity.
        if (description.isEmpty) {
          // Description is still allowed to be empty.
        }
      }

      // ----------------------------------------------------------
      // CONVERT UNIQUE UPDATES TO REPORT UPDATES
      // ----------------------------------------------------------

      for (final update in uniqueUpdates.values) {
        final String title =
            (update['title'] as String?) ?? '';

        final String description =
            (update['description'] as String?) ?? '';

        updates.add(
          ReportUpdate(
            title: title,
            description: description,
            date: _parseDate(update['date']),
            completed:
                (update['completed'] as bool?) ?? false,
          ),
        );
      }
    }

    // ------------------------------------------------------------
    // UPDATE TIMELINE COMPLETION BASED ON CURRENT REPORT STATUS
    // ------------------------------------------------------------

    _synchronizeTimelineStatus(
      updates,
      status,
    );

    // ------------------------------------------------------------
    // SORT TIMELINE
    // ------------------------------------------------------------

    updates.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return Report(
      id: (data['id'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description:
          (data['description'] as String?) ?? '',
      location:
          (data['location'] as String?) ?? '',
      category: category,
      status: status,
      priority:
          (data['priority'] as String?) ?? 'Medium',
      department:
          (data['department'] as String?) ??
              'Municipal Department',
      submittedAt:
          _parseDate(data['submitted_at']),
      icon: _getCategoryIcon(category),
      imagePath: imagePath,
      updates: updates,
    );
  }

  // ============================================================
  // SYNCHRONIZE TIMELINE WITH REPORT STATUS
  // ============================================================

  void _synchronizeTimelineStatus(
    List<ReportUpdate> updates,
    String status,
  ) {
    final String normalizedStatus =
        status.trim().toLowerCase();

    int completedStage = 0;

    switch (normalizedStatus) {
      case 'pending':
        completedStage = 1;
        break;

      case 'assigned':
        completedStage = 3;
        break;

      case 'work in progress':
        completedStage = 4;
        break;

      case 'solution submitted':
        completedStage = 4;
        break;

      case 'resolved':
        completedStage = 5;
        break;

      default:
        completedStage = 1;
    }

    for (final update in updates) {
      final String title =
          update.title.trim().toLowerCase();

      int stage = 0;

      if (title == 'report submitted') {
        stage = 1;
      } else if (title == 'under review') {
        stage = 2;
      } else if (title == 'assigned to department' ||
          title == 'assigned to industry' ||
          title == 'assigned to university') {
        stage = 3;
      } else if (title == 'work in progress' ||
          title == 'work started') {
        stage = 4;
      } else if (title == 'solution submitted') {
        stage = 4;
      } else if (title == 'resolved') {
        stage = 5;
      }

      if (stage > completedStage) {
        continue;
      }
    }
  }

  // ============================================================
  // ADD REPORT
  // ============================================================

  Future<Report> addReport({
    required String title,
    required String description,
    required String location,
    required String category,
    required String priority,
    IconData icon = Icons.report_problem_outlined,
    String? imagePath,
    List<XFile>? images,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to submit a report.',
      );
    }

    final DateTime now = DateTime.now();

    final String trackingId =
        _generateTrackingId();

    final String department =
        _getDepartment(category);

    final List<String> uploadedImagePaths = [];

    try {
      // ----------------------------------------------------------
      // UPLOAD PHOTOS TO PRIVATE SUPABASE STORAGE
      // ----------------------------------------------------------

      if (images != null && images.isNotEmpty) {
        for (
          int index = 0;
          index < images.length && index < 5;
          index++
        ) {
          final XFile image = images[index];

          final Uint8List bytes =
              await image.readAsBytes();

          if (bytes.isEmpty) {
            continue;
          }

          final String extension =
              _getFileExtension(image.name);

          final String fileName =
              'image_${index + 1}_${DateTime.now().microsecondsSinceEpoch}.$extension';

          final String storagePath =
              '${user.id}/$trackingId/$fileName';

          await _supabase.storage
              .from('report-images')
              .uploadBinary(
                storagePath,
                bytes,
                fileOptions: FileOptions(
                  contentType:
                      _getContentType(extension),
                  upsert: false,
                ),
              );

          uploadedImagePaths.add(storagePath);
        }
      } else if (imagePath != null &&
          imagePath.trim().isNotEmpty) {
        // Kept for compatibility with older callers.
        debugPrint(
          'Legacy imagePath supplied: $imagePath',
        );
      }

      // ----------------------------------------------------------
      // INSERT REPORT
      // ----------------------------------------------------------

      await _supabase.from('reports').insert({
        'id': trackingId,
        'user_id': user.id,
        'title': title.trim(),
        'description': description.trim(),
        'location': location.trim(),
        'category': category,
        'status': 'Pending',
        'priority': priority,
        'department': department,
        'submitted_at': now.toIso8601String(),
        'image_urls': uploadedImagePaths,
      });

      // ----------------------------------------------------------
      // INSERT ONLY INITIAL REPORT UPDATES
      //
      // IMPORTANT:
      // Do NOT create future stages here.
      //
      // Work Started, Solution Submitted and Resolved
      // are created when those actions actually happen.
      // ----------------------------------------------------------

      await _supabase.from('report_updates').insert([
        {
          'report_id': trackingId,
          'title': 'Report Submitted',
          'description':
              'Your report has been successfully submitted.',
          'date': now.toIso8601String(),
          'completed': true,
        },
        {
          'report_id': trackingId,
          'title': 'Under Review',
          'description':
              'Your report is waiting for verification by the concerned department.',
          'date': now.toIso8601String(),
          'completed': false,
        },
      ]);

      // ----------------------------------------------------------
      // ADD TO LOCAL CACHE
      // ----------------------------------------------------------

      final Report newReport = Report(
        id: trackingId,
        title: title.trim(),
        description: description.trim(),
        location: location.trim(),
        category: category,
        status: 'Pending',
        priority: priority,
        department: department,
        submittedAt: now,
        icon: icon == Icons.report_problem_outlined
            ? _getCategoryIcon(category)
            : icon,
        imagePath: uploadedImagePaths.isEmpty
            ? null
            : uploadedImagePaths.first,
        updates: [
          ReportUpdate(
            title: 'Report Submitted',
            description:
                'Your report has been successfully submitted.',
            date: now,
            completed: true,
          ),
          ReportUpdate(
            title: 'Under Review',
            description:
                'Your report is waiting for verification by the concerned department.',
            date: now,
            completed: false,
          ),
        ],
      );

      _reports.insert(0, newReport);

      notifyListeners();

      return newReport;
    } catch (e) {
      debugPrint(
        'Unable to create report: $e',
      );

      // ----------------------------------------------------------
      // CLEAN UP UPLOADED IMAGES IF DATABASE INSERT FAILED
      // ----------------------------------------------------------

      if (uploadedImagePaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from('report-images')
              .remove(uploadedImagePaths);
        } catch (cleanupError) {
          debugPrint(
            'Unable to clean up uploaded images: $cleanupError',
          );
        }
      }

      rethrow;
    }
  }

  // ============================================================
  // UPDATE REPORT STATUS
  // ============================================================

  Future<void> updateStatus(
    String reportId,
    String newStatus,
  ) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to update a report.',
      );
    }

    try {
      await _supabase
          .from('reports')
          .update({
            'status': newStatus,
            'updated_at':
                DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', reportId);

      final int index =
          _reports.indexWhere(
        (report) => report.id == reportId,
      );

      if (index != -1) {
        final Report report = _reports[index];

        _reports[index] = report.copyWith(
          status: newStatus,
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint(
        'Unable to update report status: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await loadReports();
  }

  // ============================================================
  // LOAD ONE REPORT BY ID
  // GET LATEST DATA FROM SUPABASE
  // ============================================================

  Future<Report?> loadReportById(
    String reportId,
  ) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      final data = await _supabase
          .from('reports')
          .select('''
            id,
            user_id,
            title,
            description,
            location,
            category,
            status,
            priority,
            department,
            submitted_at,
            image_urls,
            report_updates (
              id,
              title,
              description,
              date,
              completed
            )
          ''')
          .eq('id', reportId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      final Report latestReport =
          _reportFromSupabase(
        Map<String, dynamic>.from(data),
      );

      // ----------------------------------------------------------
      // UPDATE LOCAL CACHE WITH LATEST REPORT
      // ----------------------------------------------------------

      final int index = _reports.indexWhere(
        (report) => report.id == reportId,
      );

      if (index != -1) {
        _reports[index] = latestReport;
      } else {
        _reports.add(latestReport);
      }

      notifyListeners();

      return latestReport;
    } catch (e) {
      debugPrint(
        'Unable to load report $reportId: $e',
      );

      return null;
    }
  }

  // ============================================================
  // GENERATE TRACKING ID
  // ============================================================

  String _generateTrackingId() {
    final DateTime now = DateTime.now();

    final String datePart =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';

    final String timePart =
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    final String millisecondsPart =
        now.millisecond.toString().padLeft(3, '0');

    return 'SAH-$datePart-$timePart-$millisecondsPart';
  }

  // ============================================================
  // DEPARTMENT
  // ============================================================

  String _getDepartment(
    String category,
  ) {
    switch (category) {
      case 'Road':
      case 'Roads & Infrastructure':
        return 'Roads Department';

      case 'Drainage':
        return 'Municipal Department';

      case 'Water':
      case 'Water Supply':
        return 'Water Supply Department';

      case 'Streetlight':
      case 'Street Lights':
        return 'Electrical Department';

      case 'Electricity':
        return 'Electrical Department';

      case 'Waste':
      case 'Sanitation & Waste Management':
        return 'Waste Management Department';

      case 'Public Safety':
        return 'Public Safety Department';

      default:
        return 'Municipal Department';
    }
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Road':
      case 'Roads & Infrastructure':
        return Icons.add_road;

      case 'Drainage':
        return Icons.water_damage_outlined;

      case 'Water':
      case 'Water Supply':
        return Icons.water_drop_outlined;

      case 'Electricity':
        return Icons.electrical_services_outlined;

      case 'Streetlight':
      case 'Street Lights':
        return Icons.lightbulb_outline;

      case 'Sanitation & Waste Management':
      case 'Waste':
        return Icons.delete_outline;

      case 'Public Safety':
        return Icons.health_and_safety_outlined;

      default:
        return Icons.report_problem_outlined;
    }
  }

  // ============================================================
  // IMAGE HELPERS
  // ============================================================

  String? _firstImageUrl(
    dynamic value,
  ) {
    if (value is List &&
        value.isNotEmpty &&
        value.first is String) {
      return value.first as String;
    }

    return null;
  }

  String _getFileExtension(
    String fileName,
  ) {
    final String lowerName =
        fileName.toLowerCase();

    final int dotIndex =
        lowerName.lastIndexOf('.');

    if (dotIndex == -1 ||
        dotIndex == lowerName.length - 1) {
      return 'jpg';
    }

    final String extension =
        lowerName.substring(dotIndex + 1);

    const allowedExtensions = {
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
    };

    if (!allowedExtensions.contains(extension)) {
      return 'jpg';
    }

    return extension;
  }

  String _getContentType(
    String extension,
  ) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'gif':
        return 'image/gif';

      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  DateTime _parseDate(
    dynamic value,
  ) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now();
    }

    return DateTime.now();
  }
}