import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/storage/token_storage.dart';
import 'package:phone/features/auth/services/google_auth_service.dart';
import 'package:phone/features/auth/services/jwt_service.dart';
import 'package:phone/features/auth/services/oauth2_service.dart';
import 'package:phone/generated/jwt_controller/jwt_controller_client.dart';
import 'package:phone/generated/models/o_auth2_login_request.dart';
import 'package:phone/generated/models/refresh_token_request.dart';
import 'package:phone/generated/o_auth_2_controller/o_auth_2_controller_client.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    oAuth2Client: ref.watch(oAuth2Service),
    jwtClient: ref.watch(jwtServiceProvider),
    googleAuthService: ref.watch(googleAuthServiceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

class AuthRepository {
  final OAuth2ControllerClient _oAuth2Client;
  final JwtControllerClient _jwtClient;
  final GoogleAuthService _googleAuthService;
  final TokenStorage _tokenStorage;

  new({
    required this._oAuth2Client,
    required this._jwtClient,
    required this._googleAuthService,
    required this._tokenStorage,
  });

  Future<String?> getGoogleIdToken() async =>
      await _googleAuthService.getGoogleIdToken();

  Future<bool> authenticateGoogleTokenWithBackend(String idToken) async {
    final response = await _oAuth2Client.googleLogin(
      body: OAuth2LoginRequest(token: idToken),
    );

    await _tokenStorage.saveTokens(
      accessToken: response.jwtTokens.accessToken,
      refreshToken: response.jwtTokens.refreshToken,
    );

    return true;
  }

  Future<bool> tryAutoLogin() async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await _jwtClient.refreshTokens(
        body: RefreshTokenRequest(refreshToken: refreshToken),
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _googleAuthService.signOut();
    } finally {
      await _tokenStorage.clear();
    }
  }
}
