// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitResponse _$VisitResponseFromJson(Map<String, dynamic> json) =>
    VisitResponse(
      id: json['id'] as String,
      status: VisitResponseStatus.fromJson(json['status'] as String),
      type: VisitResponseType.fromJson(json['type'] as String),
      lessonId: json['lessonId'] as String,
      studentId: json['studentId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$VisitResponseToJson(VisitResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$VisitResponseStatusEnumMap[instance.status]!,
      'type': _$VisitResponseTypeEnumMap[instance.type]!,
      'lessonId': instance.lessonId,
      'studentId': instance.studentId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$VisitResponseStatusEnumMap = {
  VisitResponseStatus.present: 'PRESENT',
  VisitResponseStatus.absent: 'ABSENT',
  VisitResponseStatus.unmarked: 'UNMARKED',
  VisitResponseStatus.$unknown: r'$unknown',
};

const _$VisitResponseTypeEnumMap = {
  VisitResponseType.regular: 'REGULAR',
  VisitResponseType.free: 'FREE',
  VisitResponseType.unmarked: 'UNMARKED',
  VisitResponseType.$unknown: r'$unknown',
};
