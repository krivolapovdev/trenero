// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'group_summary_response.g.dart';

@JsonSerializable()
class GroupSummaryResponse {
  const GroupSummaryResponse({
    required this.id,
    required this.name,
    required this.createdAt,
    this.defaultPrice,
    this.note,
    this.countOfStudents,
  });

  factory GroupSummaryResponse.fromJson(Map<String, Object?> json) =>
      _$GroupSummaryResponseFromJson(json);

  final String id;
  final String name;
  final num? defaultPrice;
  final String? note;
  final DateTime createdAt;
  final int? countOfStudents;

  Map<String, Object?> toJson() => _$GroupSummaryResponseToJson(this);
}
