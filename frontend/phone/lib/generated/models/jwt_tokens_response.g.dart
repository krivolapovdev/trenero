// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt_tokens_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtTokensResponse _$JwtTokensResponseFromJson(Map<String, dynamic> json) =>
    JwtTokensResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$JwtTokensResponseToJson(JwtTokensResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
