// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'group_response.g.dart';

@JsonSerializable()
class GroupResponse {
  const GroupResponse({
    required this.id,
    required this.name,
    required this.createdAt,
    this.defaultPrice,
    this.note,
  });

  factory GroupResponse.fromJson(Map<String, Object?> json) =>
      _$GroupResponseFromJson(json);

  final String id;
  final String name;
  final num? defaultPrice;
  final String? note;
  final DateTime createdAt;

  Map<String, Object?> toJson() => _$GroupResponseToJson(this);
}
