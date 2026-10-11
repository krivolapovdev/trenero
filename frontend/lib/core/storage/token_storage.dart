import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phone/core/providers/secure_storage_provider.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenStorage(secureStorage);
});

class TokenStorage {
  static const _refreshTokenKey = 'REFRESH_TOKEN';

  final FlutterSecureStorage _secureStorage;

  String? _accessToken;

  new(this._secureStorage);

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<String?> getRefreshToken() async =>
      await _secureStorage.read(key: _refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    _accessToken = null;
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}
