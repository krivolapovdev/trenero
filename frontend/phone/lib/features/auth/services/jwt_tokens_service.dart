import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/models/login_response.dart';

class JwtTokensService {
  final Dio api;

  new(this.api);

  Future<LoginResponse> refreshToken(String refreshToken) async {
    final response = await api.post(
      '/api/v1/jwt/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (response.data == null) {
      throw Exception('Response data was null');
    }

    return LoginResponse.fromJson(response.data);
  }
}

final jwtTokensServiceProvider = Provider<JwtTokensService>((ref) {
  final dio = ref.watch(apiProvider);

  return JwtTokensService(dio);
});
