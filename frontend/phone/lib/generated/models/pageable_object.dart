// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sort_object.dart';

part 'pageable_object.g.dart';

@JsonSerializable()
class PageableObject {
  const PageableObject({
    required this.offset,
    required this.sort,
    required this.paged,
    required this.pageSize,
    required this.pageNumber,
    required this.unpaged,
  });

  factory PageableObject.fromJson(Map<String, Object?> json) =>
      _$PageableObjectFromJson(json);

  final int offset;
  final SortObject sort;
  final bool paged;
  final int pageSize;
  final int pageNumber;
  final bool unpaged;

  Map<String, Object?> toJson() => _$PageableObjectToJson(this);
}
