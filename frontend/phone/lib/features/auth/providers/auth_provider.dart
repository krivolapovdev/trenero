import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phone/core/providers/secure_storage_provider.dart';
import 'package:phone/core/providers/shared_preferences_provider.dart';
import 'package:phone/core/providers/token_provider.dart';
import 'package:phone/features/auth/services/google_auth_service.dart';
import 'package:phone/features/auth/services/jwt_tokens_service.dart';
import 'package:phone/features/auth/services/oauth2_service.dart';
import 'package:phone/generated/models/login_response.dart';
import 'package:phone/generated/models/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _userStorageKey = 'user';
const String _refreshTokenKey = 'refresh_token';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authInitializerProvider = FutureProvider<bool>(
  (ref) async => await ref.read(authProvider.notifier).tryRefreshToken(),
);

class AuthState {
  final UserResponse? user;

  const new({this.user});
}

class AuthNotifier extends Notifier<AuthState> {
  late final SharedPreferences _prefs;
  late final FlutterSecureStorage _secureStorage;

  @override
  AuthState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    _secureStorage = ref.watch(secureStorageProvider);
    return const AuthState();
  }

  Future<void> signInWithGoogle({required VoidCallback onTokenReceived}) async {
    final googleAuthService = ref.read(googleAuthServiceProvider);
    final oAuth2Service = ref.read(oAuth2ServiceProvider);

    final String? token = await googleAuthService.getGoogleIdToken();

    if (token == null || token.isEmpty) {
      return;
    }

    onTokenReceived();

    final LoginResponse response = await oAuth2Service.googleLogin(token);
    await setAuth(response);
  }

  Future<void> setAuth(LoginResponse payload) async {
    state = AuthState(user: payload.user);

    ref.read(tokenProvider.notifier).setToken(payload.jwtTokens.accessToken);

    final String userJson = jsonEncode(payload.user.toJson());
    await _prefs.setString(_userStorageKey, userJson);

    await _secureStorage.write(
      key: _refreshTokenKey,
      value: payload.jwtTokens.refreshToken,
    );
  }

  Future<bool> tryRefreshToken() async {
    final String? refreshToken = await getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      await clear();
      return false;
    }

    try {
      final jwtTokensService = ref.read(jwtTokensServiceProvider);

      final LoginResponse response = await jwtTokensService.refreshToken(
        refreshToken,
      );

      await setAuth(response);
      return true;
    } catch (_) {
      await clear();
      return false;
    }
  }

  Future<void> clear() async {
    state = const AuthState();

    ref.read(tokenProvider.notifier).setToken(null);

    await _prefs.remove(_userStorageKey);
    await _secureStorage.delete(key: _refreshTokenKey);

    try {
      final googleAuthService = ref.read(googleAuthServiceProvider);
      await googleAuthService.signOut();
    } catch (e) {
      log('Google sign out error: $e');
    }
  }

  Future<String?> getRefreshToken() async =>
      await _secureStorage.read(key: _refreshTokenKey);
}
