// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_group_request.g.dart';

@JsonSerializable()
class CreateGroupRequest {
  const CreateGroupRequest({
    required this.name,
    this.defaultPrice,
    this.note,
    this.studentIds,
  });

  factory CreateGroupRequest.fromJson(Map<String, Object?> json) =>
      _$CreateGroupRequestFromJson(json);

  final String name;
  final num? defaultPrice;
  final String? note;
  final List<String>? studentIds;

  Map<String, Object?> toJson() => _$CreateGroupRequestToJson(this);
}
