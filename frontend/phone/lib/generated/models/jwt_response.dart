// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'jwt_response.g.dart';

@JsonSerializable()
class JwtResponse {
  const JwtResponse({required this.accessToken, required this.refreshToken});

  factory JwtResponse.fromJson(Map<String, Object?> json) =>
      _$JwtResponseFromJson(json);

  final String accessToken;
  final String refreshToken;

  Map<String, Object?> toJson() => _$JwtResponseToJson(this);
}
