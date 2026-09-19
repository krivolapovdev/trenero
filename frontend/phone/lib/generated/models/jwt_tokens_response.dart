// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'jwt_tokens_response.g.dart';

@JsonSerializable()
class JwtTokensResponse {
  const JwtTokensResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory JwtTokensResponse.fromJson(Map<String, Object?> json) =>
      _$JwtTokensResponseFromJson(json);

  final String accessToken;
  final String refreshToken;

  Map<String, Object?> toJson() => _$JwtTokensResponseToJson(this);
}
