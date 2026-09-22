import 'package:phone/generated/models/login_response.dart';
import 'package:phone/generated/models/o_auth2_login_request.dart';
import 'package:phone/core/api/api.dart';

class OAuth2Service {
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

final OAuth2Service oAuth2Service = OAuth2Service();
