// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupDetailsResponse _$GroupDetailsResponseFromJson(
  Map<String, dynamic> json,
) => GroupDetailsResponse(
  id: json['id'] as String,
  name: json['name'] as String,
  groupStudents: (json['groupStudents'] as List<dynamic>)
      .map((e) => StudentResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  groupLessons: (json['groupLessons'] as List<dynamic>)
      .map((e) => LessonResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  defaultPrice: json['defaultPrice'] as num?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$GroupDetailsResponseToJson(
  GroupDetailsResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'defaultPrice': instance.defaultPrice,
  'note': instance.note,
  'groupStudents': instance.groupStudents,
  'createdAt': instance.createdAt.toIso8601String(),
  'groupLessons': instance.groupLessons,
};
