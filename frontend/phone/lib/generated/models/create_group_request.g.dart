// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateGroupRequest _$CreateGroupRequestFromJson(Map<String, dynamic> json) =>
    CreateGroupRequest(
      name: json['name'] as String,
      defaultPrice: json['defaultPrice'] as num?,
      note: json['note'] as String?,
      studentIds: (json['studentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateGroupRequestToJson(CreateGroupRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'defaultPrice': instance.defaultPrice,
      'note': instance.note,
      'studentIds': instance.studentIds,
    };
