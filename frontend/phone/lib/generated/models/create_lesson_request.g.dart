// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_lesson_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateLessonRequest _$CreateLessonRequestFromJson(Map<String, dynamic> json) =>
    CreateLessonRequest(
      groupId: json['groupId'] as String,
      date: DateTime.parse(json['date'] as String),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => StudentVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreateLessonRequestToJson(
  CreateLessonRequest instance,
) => <String, dynamic>{
  'groupId': instance.groupId,
  'date': instance.date.toIso8601String(),
  'students': instance.students,
};
