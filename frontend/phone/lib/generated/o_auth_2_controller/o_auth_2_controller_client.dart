// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/login_response.dart';
import '../models/o_auth2_login_request.dart';

part 'o_auth_2_controller_client.g.dart';

@RestApi()
abstract class OAuth2ControllerClient {
  factory OAuth2ControllerClient(Dio dio, {String? baseUrl}) =
      _OAuth2ControllerClient;

  @POST('/api/v1/oauth2/google')
  Future<LoginResponse> googleLogin({@Body() required OAuth2LoginRequest body});

  @POST('/api/v1/oauth2/apple')
  Future<LoginResponse> appleLogin({@Body() required OAuth2LoginRequest body});

  @GET('/api/v1/oauth2/test')
  Future<String> test();
}
