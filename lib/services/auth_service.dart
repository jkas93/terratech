import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => _client.auth.currentUser != null;
  String? get userId => _client.auth.currentUser?.id;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName, 'xp': 0, 'level': 1},
    );

    if (response.user != null) {
      await _createUserProfile(
        id: response.user!.id,
        email: email,
        displayName: displayName,
      );
    }

    return response;
  }

  Future<bool> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.terratech.app://callback',
    );
    return true;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.terratech.app://reset-password',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('user_profiles').upsert({
      'id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _createUserProfile({
    required String id,
    required String email,
    String? displayName,
  }) async {
    await _client.from('user_profiles').insert({
      'id': id,
      'email': email,
      'display_name': displayName ?? email.split('@').first,
      'xp': 0,
      'level': 1,
    });
  }

  Session? get currentSession => _client.auth.currentSession;
  String? get accessToken => _client.auth.currentSession?.accessToken;
}
