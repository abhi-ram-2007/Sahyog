import 'package:supabase_flutter/supabase_flutter.dart';

class ReportAssignmentStore {
  ReportAssignmentStore._();

  static final ReportAssignmentStore instance =
      ReportAssignmentStore._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // CURRENT USER
  // ============================================================

  User get _currentUser {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'No authenticated user found. Please log in again.',
      );
    }

    return user;
  }

  String get _userId => _currentUser.id;

  // ============================================================
  // LOAD GOVERNMENT REPORTS
  // ============================================================

  Future<List<Map<String, dynamic>>> loadGovernmentReports() async {
    final rows = await _supabase
        .from('reports')
        .select(
          'id,title,description,location,category,status,priority,'
          'department,submitted_at,user_id',
        )
        .order('submitted_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  // ============================================================
  // LOAD INDUSTRY / UNIVERSITY USERS
  // ============================================================

  Future<List<Map<String, dynamic>>> loadOrganizations(
    String role,
  ) async {
    final normalizedRole = role.trim().toLowerCase();

    final rows = await _supabase
        .from('profiles')
        .select('id,full_name,email,role')
        .ilike('role', normalizedRole)
        .order('full_name', ascending: true);

    return List<Map<String, dynamic>>.from(rows);
  }

  // ============================================================
  // LOAD ASSIGNMENTS FOR INDUSTRY / UNIVERSITY
  // ============================================================

  Future<List<Map<String, dynamic>>> loadAssignmentsForUser(
    String role,
  ) async {
    final normalizedRole = role.trim().toLowerCase();

    final rows = await _supabase
        .from('report_assignments')
        .select(
          'id,'
          'report_id,'
          'assigned_by,'
          'assigned_to,'
          'assigned_role,'
          'status,'
          'instructions,'
          'assigned_at,'
          'completed_at,'
          'reports('
          'id,'
          'title,'
          'description,'
          'location,'
          'category,'
          'status,'
          'priority,'
          'department,'
          'submitted_at'
          ')',
        )
        .eq('assigned_to', _userId)
        .ilike('assigned_role', normalizedRole)
        .order('assigned_at', ascending: false);

    return List<Map<String, dynamic>>.from(rows);
  }

  // ============================================================
  // ADD TIMELINE UPDATE ONLY IF IT DOES NOT ALREADY EXIST
  // ============================================================

  Future<void> _addTimelineUpdate({
    required String reportId,
    required String title,
    required String description,
    required bool completed,
  }) async {
    final existing = await _supabase
        .from('report_updates')
        .select('id')
        .eq('report_id', reportId)
        .eq('title', title)
        .limit(1);

    if (existing.isNotEmpty) {
      return;
    }

    await _supabase.from('report_updates').insert({
      'report_id': reportId,
      'title': title,
      'description': description,
      'completed': completed,
    });
  }

  // ============================================================
  // ASSIGN REPORT TO INDUSTRY / UNIVERSITY
  // ============================================================

  Future<void> assignReport({
    required String reportId,
    required String assignedTo,
    required String assignedRole,
    required String instructions,
  }) async {
    final normalizedRole = assignedRole.trim().toLowerCase();
    final cleanInstructions = instructions.trim();

    if (normalizedRole != 'industry' &&
        normalizedRole != 'university') {
      throw Exception('Invalid assignment role.');
    }

    // ----------------------------------------------------------
    // 1. GET CURRENT AUTHENTICATED USER
    // ----------------------------------------------------------

    final user = _currentUser;

    // Debug information
    // print('==========================================');
    // print('SAHYOG ASSIGNMENT DEBUG');
    // print('User ID: ${user.id}');
    // print('User Email: ${user.email}');
    // print('Assigned To: $assignedTo');
    // print('Assigned Role: $normalizedRole');
    // print('Report ID: $reportId');
    // print('==========================================');

    // ----------------------------------------------------------
    // 2. VERIFY THAT CURRENT USER IS GOVERNMENT
    // ----------------------------------------------------------

    final profile = await _supabase
        .from('profiles')
        .select('id,email,full_name,role')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      throw Exception(
        'Your user profile was not found. '
        'Please log out and register/login again.',
      );
    }

    final profileRole =
        (profile['role'] ?? '').toString().trim().toLowerCase();

    // print('Profile Role: $profileRole');

    if (profileRole != 'government') {
      throw Exception(
        'Only a Government account can assign reports. '
        'Current role: $profileRole',
      );
    }

    // ----------------------------------------------------------
    // 3. CREATE ASSIGNMENT
    // ----------------------------------------------------------

    await _supabase.from('report_assignments').insert({
      'report_id': reportId,

      // MUST match auth.uid()
      'assigned_by': user.id,

      // UUID of Industry / University profile
      'assigned_to': assignedTo,

      'assigned_role': normalizedRole,

      'status': 'Assigned',

      'instructions': cleanInstructions,

      // Required NOT NULL column
      'assigned_at':
          DateTime.now().toUtc().toIso8601String(),
    });

    // ----------------------------------------------------------
    // 4. UPDATE REPORT STATUS
    // ----------------------------------------------------------

    await _supabase
        .from('reports')
        .update({
          'status': 'Assigned',
          'updated_at':
              DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', reportId);

    // ----------------------------------------------------------
    // 5. ADD ASSIGNMENT TIMELINE UPDATE
    // ----------------------------------------------------------

    final assignmentTitle =
        normalizedRole == 'industry'
            ? 'Assigned to Industry'
            : 'Assigned to University';

    await _addTimelineUpdate(
      reportId: reportId,
      title: assignmentTitle,
      description: cleanInstructions.isEmpty
          ? 'Government assigned this report for further action.'
          : cleanInstructions,
      completed: false,
    );
  }

  // ============================================================
  // UPDATE ASSIGNMENT STATUS
  // ============================================================

  Future<void> updateAssignmentStatus({
    required int assignmentId,
    required String reportId,
    required String newStatus,
    required String updateTitle,
  }) async {
    final normalizedStatus = newStatus.trim().toLowerCase();

    final values = <String, dynamic>{
      'status': newStatus,
    };

    if (normalizedStatus == 'completed') {
      values['completed_at'] =
          DateTime.now().toUtc().toIso8601String();
    }

    // ----------------------------------------------------------
    // 1. UPDATE ASSIGNMENT
    // ----------------------------------------------------------

    await _supabase
        .from('report_assignments')
        .update(values)
        .eq('id', assignmentId)
        .eq('assigned_to', _userId);

    // ----------------------------------------------------------
    // 2. CONVERT ASSIGNMENT STATUS TO REPORT STATUS
    // ----------------------------------------------------------

    final reportStatus = switch (normalizedStatus) {
      'accepted' => 'Assigned',
      'in progress' => 'Work in Progress',
      'completed' => 'Solution Submitted',
      _ => 'Assigned',
    };

    // ----------------------------------------------------------
    // 3. UPDATE REPORT
    // ----------------------------------------------------------

    await _supabase
        .from('reports')
        .update({
          'status': reportStatus,
          'updated_at':
              DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', reportId);

    // ----------------------------------------------------------
    // 4. ADD TIMELINE UPDATE
    // ----------------------------------------------------------

    await _addTimelineUpdate(
      reportId: reportId,
      title: updateTitle,
      description:
          'Assigned team updated the report status to $newStatus.',
      completed: normalizedStatus == 'completed',
    );
  }

  // ============================================================
  // GOVERNMENT VERIFIES AND RESOLVES REPORT
  // ============================================================

  Future<void> resolveReport(String reportId) async {
    // ----------------------------------------------------------
    // 1. UPDATE REPORT
    // ----------------------------------------------------------

    await _supabase
        .from('reports')
        .update({
          'status': 'Resolved',
          'updated_at':
              DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', reportId);

    // ----------------------------------------------------------
    // 2. ADD RESOLVED TIMELINE UPDATE
    // ----------------------------------------------------------

    await _addTimelineUpdate(
      reportId: reportId,
      title: 'Resolved',
      description:
          'Government verified the submitted solution and resolved the report.',
      completed: true,
    );
  }
}