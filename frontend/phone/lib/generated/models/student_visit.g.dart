// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentVisit _$StudentVisitFromJson(Map<String, dynamic> json) => StudentVisit(
  studentId: json['studentId'] as String?,
  status: json['status'] == null
      ? null
      : StudentVisitStatus.fromJson(json['status'] as String),
  type: json['type'] == null
      ? null
      : StudentVisitType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StudentVisitToJson(StudentVisit instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'status': _$StudentVisitStatusEnumMap[instance.status],
      'type': _$StudentVisitTypeEnumMap[instance.type],
    };

const _$StudentVisitStatusEnumMap = {
  StudentVisitStatus.present: 'PRESENT',
  StudentVisitStatus.absent: 'ABSENT',
  StudentVisitStatus.unmarked: 'UNMARKED',
  StudentVisitStatus.$unknown: r'$unknown',
};

const _$StudentVisitTypeEnumMap = {
  StudentVisitType.regular: 'REGULAR',
  StudentVisitType.free: 'FREE',
  StudentVisitType.unmarked: 'UNMARKED',
  StudentVisitType.$unknown: r'$unknown',
};
