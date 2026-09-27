import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/models/login_response.dart';
import 'package:phone/generated/models/o_auth2_login_request.dart';

class OAuth2Service {
  final Dio api;

  new(this.api);

  Future<LoginResponse> googleLogin(String token) async {
    final requestBody = OAuth2LoginRequest(token: token);

    final response = await api.post<Map<String, dynamic>>(
      '/api/v1/oauth2/google',
      data: requestBody.toJson(),
    );

    if (response.data == null) {
      throw Exception('Response data was null');
    }

    return LoginResponse.fromJson(response.data!);
  }
}

final oAuth2ServiceProvider = Provider<OAuth2Service>((ref) {
  final dio = ref.watch(apiProvider);

  return OAuth2Service(dio);
});
