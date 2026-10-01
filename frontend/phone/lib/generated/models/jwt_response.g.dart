// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtResponse _$JwtResponseFromJson(Map<String, dynamic> json) => JwtResponse(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$JwtResponseToJson(JwtResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
