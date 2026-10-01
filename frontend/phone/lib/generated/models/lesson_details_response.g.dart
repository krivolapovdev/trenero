// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonDetailsResponse _$LessonDetailsResponseFromJson(
  Map<String, dynamic> json,
) => LessonDetailsResponse(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  studentVisits: (json['studentVisits'] as List<dynamic>)
      .map((e) => VisitResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LessonDetailsResponseToJson(
  LessonDetailsResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'date': instance.date.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'studentVisits': instance.studentVisits,
};
