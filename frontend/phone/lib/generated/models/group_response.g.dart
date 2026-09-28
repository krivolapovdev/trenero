// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupResponse _$GroupResponseFromJson(Map<String, dynamic> json) =>
    GroupResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      defaultPrice: json['defaultPrice'] as num?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$GroupResponseToJson(GroupResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'defaultPrice': instance.defaultPrice,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };
