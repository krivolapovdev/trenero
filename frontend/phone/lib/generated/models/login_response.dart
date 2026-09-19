// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'jwt_tokens_response.dart';
import 'user_response.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  const LoginResponse({required this.user, required this.jwtTokens});

  factory LoginResponse.fromJson(Map<String, Object?> json) =>
      _$LoginResponseFromJson(json);

  final UserResponse user;
  final JwtTokensResponse jwtTokens;

  Map<String, Object?> toJson() => _$LoginResponseToJson(this);
}
