import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
      },
    );
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  // ============================================================
  // GET USER ROLE
  // ============================================================

  Future<String> getUserRole() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final profile = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    return profile['role'] as String;
  }

  // ============================================================
  // GET FULL PROFILE
  // ============================================================

  Future<Map<String, dynamic>> getProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}