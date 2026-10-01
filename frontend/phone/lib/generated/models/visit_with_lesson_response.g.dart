// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_with_lesson_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitWithLessonResponse _$VisitWithLessonResponseFromJson(
  Map<String, dynamic> json,
) => VisitWithLessonResponse(
  visit: VisitResponse.fromJson(json['visit'] as Map<String, dynamic>),
  lesson: LessonResponse.fromJson(json['lesson'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VisitWithLessonResponseToJson(
  VisitWithLessonResponse instance,
) => <String, dynamic>{'visit': instance.visit, 'lesson': instance.lesson};
