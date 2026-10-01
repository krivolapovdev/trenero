// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_visit_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateVisitRequest _$CreateVisitRequestFromJson(Map<String, dynamic> json) =>
    CreateVisitRequest(
      lessonId: json['lessonId'] as String,
      studentId: json['studentId'] as String,
      status: CreateVisitRequestStatus.fromJson(json['status'] as String),
      type: CreateVisitRequestType.fromJson(json['type'] as String),
    );

Map<String, dynamic> _$CreateVisitRequestToJson(CreateVisitRequest instance) =>
    <String, dynamic>{
      'lessonId': instance.lessonId,
      'studentId': instance.studentId,
      'status': _$CreateVisitRequestStatusEnumMap[instance.status]!,
      'type': _$CreateVisitRequestTypeEnumMap[instance.type]!,
    };

const _$CreateVisitRequestStatusEnumMap = {
  CreateVisitRequestStatus.present: 'PRESENT',
  CreateVisitRequestStatus.absent: 'ABSENT',
  CreateVisitRequestStatus.unmarked: 'UNMARKED',
  CreateVisitRequestStatus.$unknown: r'$unknown',
};

const _$CreateVisitRequestTypeEnumMap = {
  CreateVisitRequestType.regular: 'REGULAR',
  CreateVisitRequestType.free: 'FREE',
  CreateVisitRequestType.unmarked: 'UNMARKED',
  CreateVisitRequestType.$unknown: r'$unknown',
};
