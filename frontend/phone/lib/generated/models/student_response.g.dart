// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentResponse _$StudentResponseFromJson(Map<String, dynamic> json) =>
    StudentResponse(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      birthdate: json['birthdate'] == null
          ? null
          : DateTime.parse(json['birthdate'] as String),
      phone: json['phone'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$StudentResponseToJson(StudentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'birthdate': instance.birthdate?.toIso8601String(),
      'phone': instance.phone,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
    };
