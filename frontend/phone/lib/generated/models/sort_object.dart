// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'sort_object.g.dart';

@JsonSerializable()
class SortObject {
  const SortObject({
    required this.empty,
    required this.sorted,
    required this.unsorted,
  });

  factory SortObject.fromJson(Map<String, Object?> json) =>
      _$SortObjectFromJson(json);

  final bool empty;
  final bool sorted;
  final bool unsorted;

  Map<String, Object?> toJson() => _$SortObjectToJson(this);
}
