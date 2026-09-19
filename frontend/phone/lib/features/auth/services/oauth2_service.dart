import 'package:phone/share/services/api.dart';

class OAuth2Service {
  Future<LoginResponse> googleLogin(String token) async {
    final requestBody = GoogleLoginRequest(token: token);

    final response = await api.post<Map<String, dynamic>>(
      '/api/v1/oauth2/google',
      data: requestBody.toJson(),
    );

    if (response.data == null) {
      throw Exception('Response data was null');
    }

    print('Google Login Response: ${response.data}');

    return LoginResponse.fromJson(response.data!);
  }
}

class GoogleLoginRequest {
  final String token;

  const GoogleLoginRequest({required this.token});

  Map<String, dynamic> toJson() => {'token': token};
}

class LoginResponse {
  final String? accessToken;
  final String? refreshToken;

  const LoginResponse({this.accessToken, this.refreshToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final jwtTokens = json['jwtTokens'] as Map<String, dynamic>?;

    return LoginResponse(
      accessToken: jwtTokens?['accessToken'] as String?,
      refreshToken: jwtTokens?['refreshToken'] as String?,
    );
  }
}
