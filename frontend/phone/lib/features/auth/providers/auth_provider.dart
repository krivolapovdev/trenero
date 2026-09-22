import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phone/core/providers/secure_storage_provider.dart';
import 'package:phone/core/providers/shared_preferences_provider.dart';
import 'package:phone/features/auth/services/jwt_tokens_service.dart';
import 'package:phone/generated/models/login_response.dart';
import 'package:phone/generated/models/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _userStorageKey = 'user';
const String _refreshTokenKey = 'refresh_token';

class AuthState {
  final UserResponse? user;
  final String? accessToken;

  const new({this.user, this.accessToken});
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

  Future<void> setAuth(LoginResponse payload) async {
    state = AuthState(
      user: payload.user,
      accessToken: payload.jwtTokens.accessToken,
    );

    final String userJson = jsonEncode(payload.user.toJson());
    await _prefs.setString(_userStorageKey, userJson);

    await _secureStorage.write(
      key: _refreshTokenKey,
      value: payload.jwtTokens.refreshToken,
    );
  }

  Future<bool> tryRefreshToken() async {
    final String? refreshToken = await getRefreshToken();

    // throw Exception('Refresh token is null or empty');

    if (refreshToken == null || refreshToken.isEmpty) {
      await clear();
      return false;
    }

    try {
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
    await _prefs.remove(_userStorageKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authInitializerProvider = FutureProvider<bool>((ref) async {
  return await ref.read(authProvider.notifier).tryRefreshToken();
});
