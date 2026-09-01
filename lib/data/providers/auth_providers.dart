import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../services/auth_service.dart';
import 'database_providers.dart';

// ---- Supabase Auth -----------------------------------------------------------

/// Auth state machine for the whole app.
enum AuthStatus { signedOut, signedIn, guest }

class AuthState {
  const AuthState({this.status = AuthStatus.signedOut, this.email, this.name});

  final AuthStatus status;
  final String? email;
  final String? name; // display name

  AuthState copyWith({AuthStatus? status, String? email, String? name}) =>
      AuthState(
        status: status ?? this.status,
        email: email ?? this.email,
        name: name ?? this.name,
      );
}

/// Wraps the Supabase client.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Drives the app's authentication state.
class AuthController extends Notifier<AuthState> {
  static const _kGuestMode = 'guest_mode';
  StreamSubscription? _authSub;

  @override
  AuthState build() {
    final service = ref.watch(authServiceProvider);
    if (!service.isConfigured) {
      // App is fully usable offline — no login flow.
      return const AuthState(status: AuthStatus.guest);
    }

    _authSub?.cancel();
    _authSub =
        supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AuthState(
          status: AuthStatus.signedIn,
          email: session.user.email,
          name: session.user.userMetadata?['name'] as String?,
        );
      } else {
        if (state.status != AuthStatus.guest) {
          state = const AuthState(status: AuthStatus.signedOut);
        }
      }
    });
    ref.onDispose(() => _authSub?.cancel());

    // Existing Supabase session wins over guest mode.
    if (service.currentUserId != null) {
      return AuthState(
        status: AuthStatus.signedIn,
        email: service.currentEmail,
        name: service.currentUserName,
      );
    }
    // Guest mode is remembered across sessions.
    final guest = ref.read(sharedPreferencesProvider).getBool(_kGuestMode);
    if (guest ?? false) {
      return const AuthState(status: AuthStatus.guest);
    }
    return const AuthState(status: AuthStatus.signedOut);
  }

  /// Signs in with email + password. Throws [AuthException] on failure.
  Future<void> signIn(String email, String password) async {
    final service = ref.read(authServiceProvider);
    await service.signInWithEmail(email, password);
    state = AuthState(
      status: AuthStatus.signedIn,
      email: service.currentEmail,
      name: service.currentUserName,
    );
  }

  /// Creates an account (sets user metadata `name`), then signs in.
  /// Throws [AuthException] on failure.
  Future<void> signUp(String name, String email, String password) async {
    final service = ref.read(authServiceProvider);
    await service.signUpWithEmail(name, email, password);
    if (service.currentUserId != null) {
      state = AuthState(
        status: AuthStatus.signedIn,
        email: service.currentEmail,
        name: service.currentUserName ?? name,
      );
    } else {
      // No session after signup — email confirmation is required.
      throw const AuthException('confirmEmail');
    }
  }

  /// Signs in with Facebook OAuth. Throws [AuthException] on failure.
  Future<void> signInWithFacebook() async {
    final service = ref.read(authServiceProvider);
    await service.signInWithFacebook();
    // OAuth membutuhkan waktu — state diupdate oleh onAuthStateChange listener.
  }

  /// Enters the app as a guest — persisted so it survives restarts.
  Future<void> continueAsGuest() async {
    await ref.read(sharedPreferencesProvider).setBool(_kGuestMode, true);
    state = const AuthState(status: AuthStatus.guest);
  }

  /// Signs out and clears guest mode.
  Future<void> signOut() async {
    final service = ref.read(authServiceProvider);
    await service.signOut();
    await ref.read(sharedPreferencesProvider).remove(_kGuestMode);
    state = const AuthState(status: AuthStatus.signedOut);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);