// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_student_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupStudentResponse _$GroupStudentResponseFromJson(
  Map<String, dynamic> json,
) => GroupStudentResponse(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  studentId: json['studentId'] as String,
  leftAt: json['leftAt'] == null
      ? null
      : DateTime.parse(json['leftAt'] as String),
);

Map<String, dynamic> _$GroupStudentResponseToJson(
  GroupStudentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'studentId': instance.studentId,
  'leftAt': instance.leftAt?.toIso8601String(),
};
