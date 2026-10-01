// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupDetails _$GroupDetailsFromJson(Map<String, dynamic> json) => GroupDetails(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  groupStudents: (json['groupStudents'] as List<dynamic>)
      .map((e) => StudentResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  groupLessons: (json['groupLessons'] as List<dynamic>)
      .map((e) => LessonResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  defaultPrice: json['defaultPrice'] as num?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$GroupDetailsToJson(GroupDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'defaultPrice': instance.defaultPrice,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'groupStudents': instance.groupStudents,
      'groupLessons': instance.groupLessons,
    };
