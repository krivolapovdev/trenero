// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_lesson_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateLessonRequest _$UpdateLessonRequestFromJson(Map<String, dynamic> json) =>
    UpdateLessonRequest(
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => StudentVisit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UpdateLessonRequestToJson(
  UpdateLessonRequest instance,
) => <String, dynamic>{
  'date': instance.date?.toIso8601String(),
  'students': instance.students,
};
