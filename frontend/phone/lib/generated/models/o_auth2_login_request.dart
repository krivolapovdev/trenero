// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'o_auth2_login_request.g.dart';

@JsonSerializable()
class OAuth2LoginRequest {
  const OAuth2LoginRequest({required this.token});

  factory OAuth2LoginRequest.fromJson(Map<String, Object?> json) =>
      _$OAuth2LoginRequestFromJson(json);

  final String token;

  Map<String, Object?> toJson() => _$OAuth2LoginRequestToJson(this);
}
