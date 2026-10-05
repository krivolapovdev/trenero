// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentVisit _$StudentVisitFromJson(Map<String, dynamic> json) => StudentVisit(
  studentId: json['studentId'] as String,
  status: VisitStatus.fromJson(json['status'] as String),
  type: VisitType.fromJson(json['type'] as String),
);

Map<String, dynamic> _$StudentVisitToJson(StudentVisit instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'status': _$VisitStatusEnumMap[instance.status]!,
      'type': _$VisitTypeEnumMap[instance.type]!,
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
