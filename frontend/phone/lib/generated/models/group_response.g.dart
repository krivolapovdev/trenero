// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupResponse _$GroupResponseFromJson(Map<String, dynamic> json) =>
    GroupResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      groupStudents: (json['groupStudents'] as List<dynamic>)
          .map((e) => StudentResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'groupStudents': instance.groupStudents,
      'createdAt': instance.createdAt.toIso8601String(),
    };
