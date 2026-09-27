// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/jwt_tokens_response.dart';
import '../models/refresh_token_request.dart';

part 'jwt_controller_client.g.dart';

@RestApi()
abstract class JwtControllerClient {
  factory JwtControllerClient(Dio dio, {String? baseUrl}) =
      _JwtControllerClient;

  @POST('/api/v1/jwt/refresh')
  Future<JwtTokensResponse> refreshTokens({
    @Body() required RefreshTokenRequest body,
  });
}
