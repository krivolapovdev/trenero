import 'package:phone/generated/models/login_response.dart';
import 'package:phone/core/api/api.dart';

class JwtTokensService {
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

final JwtTokensService jwtTokensService = JwtTokensService();
