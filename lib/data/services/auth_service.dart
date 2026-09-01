import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../core/supabase_config.dart';

/// L10n message-key identifiers for auth failures.
/// UI lane maps these to the corresponding `authError*` ARB keys.
class AuthException implements Exception {
  const AuthException(this.messageKey);
  final String messageKey;

  /// The raw l10n message key (e.g. `emailInUse`) — the UI lane maps
  /// `error.toString()` to the matching `authError*` ARB key.
  @override
  String toString() => messageKey;
}

/// Thin wrapper around the Supabase Auth client.
///
/// All methods are safe to call even when [isConfigured] is false — they will
/// throw [AuthException] with `generic` if accessed before initialization.
class AuthService {
  bool get isConfigured => SupabaseConfig.isConfigured;

  supabase.GoTrueClient get _auth => supabase.Supabase.instance.client.auth;

  String? get currentUserId => _auth.currentUser?.id;
  String? get currentEmail => _auth.currentUser?.email;
  String? get currentUserName =>
      _auth.currentUser?.userMetadata?['name'] as String?;

  Future<void> signInWithEmail(String email, String password) async {
    _guardConfigured();
    try {
      await _auth.signInWithPassword(email: email, password: password);
    } on supabase.AuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> signUpWithEmail(String name, String email, String password) async {
    _guardConfigured();
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (res.session == null && res.user != null) {
        // Tidak ada session → butuh konfirmasi email ATAU email sudah terdaftar.
        // user_repeated_signup (200 OK) untuk email yang sudah confirmed → emailConfirmedAt != null.
        final alreadyConfirmed = res.user!.emailConfirmedAt != null;
        if (alreadyConfirmed) {
          throw const AuthException('emailInUse');
        }
        throw const AuthException('confirmEmail');
      }
    } on supabase.AuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> signOut() async {
    _guardConfigured();
    try {
      await _auth.signOut();
    } on supabase.AuthException catch (e) {
      throw _mapError(e);
    }
  }

  /// Signs in with Facebook OAuth. Throws [AuthException] on failure.
  Future<void> signInWithFacebook() async {
    _guardConfigured();
    try {
      await _auth.signInWithOAuth(
        supabase.OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutter://callback',
      );
    } on supabase.AuthException catch (e) {
      throw _mapError(e);
    }
  }

  void _guardConfigured() {
    if (!isConfigured) {
      throw const AuthException('generic');
    }
  }

  static AuthException _mapError(supabase.AuthException error) {
    final msg = error.message.toLowerCase();
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already exists')) {
      return const AuthException('emailInUse');
    }
    if (msg.contains('invalid login credentials')) {
      return const AuthException('invalidCredentials');
    }
    if (msg.contains('password') &&
        (msg.contains('short') || msg.contains('6 characters') || msg.contains('at least'))) {
      return const AuthException('weakPassword');
    }
    if (msg.contains('invalid email') ||
        msg.contains('email address') ||
        msg.contains('email not allowed') ||
        msg.contains('unable to validate')) {
      return const AuthException('invalidEmail');
    }
    return const AuthException('generic');
  }
}