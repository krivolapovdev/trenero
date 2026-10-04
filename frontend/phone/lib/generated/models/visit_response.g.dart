// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitResponse _$VisitResponseFromJson(Map<String, dynamic> json) =>
    VisitResponse(
      id: json['id'] as String,
      status: VisitStatus.fromJson(json['status'] as String),
      type: VisitType.fromJson(json['type'] as String),
      lessonId: json['lessonId'] as String,
      studentId: json['studentId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$VisitResponseToJson(VisitResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$VisitStatusEnumMap[instance.status]!,
      'type': _$VisitTypeEnumMap[instance.type]!,
      'lessonId': instance.lessonId,
      'studentId': instance.studentId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$VisitStatusEnumMap = {
  VisitStatus.present: 'PRESENT',
  VisitStatus.absent: 'ABSENT',
  VisitStatus.unmarked: 'UNMARKED',
  VisitStatus.$unknown: r'$unknown',
};

const _$VisitTypeEnumMap = {
  VisitType.regular: 'REGULAR',
  VisitType.free: 'FREE',
  VisitType.unmarked: 'UNMARKED',
  VisitType.$unknown: r'$unknown',
};
