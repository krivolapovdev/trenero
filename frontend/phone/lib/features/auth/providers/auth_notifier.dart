import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/auth/repository/auth_repository.dart';

enum AuthStatus { authenticated, unauthenticated }

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthStatus>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthStatus> {
  bool _isSigningIn = false;

  @override
  Future<AuthStatus> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final isLoggedIn = await repository.tryAutoLogin();

    return isLoggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<void> signInWithGoogle() async {
    if (_isSigningIn) return;
    _isSigningIn = true;

    try {
      final repository = ref.read(authRepositoryProvider);

      final idToken = await repository.getGoogleIdToken();

      if (idToken == null) {
        return;
      }

      state = const AsyncLoading();

      state = await AsyncValue.guard(() async {
        final success = await repository.authenticateGoogleTokenWithBackend(
          idToken,
        );

        return success ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      });
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _isSigningIn = false;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return AuthStatus.unauthenticated;
    });
  }

  /// Opens the session without a sign in request.
  ///
  /// Used after the reviewer key was accepted by the backend.
  void markAuthenticated() {
    state = const AsyncData(AuthStatus.authenticated);
  }
}
