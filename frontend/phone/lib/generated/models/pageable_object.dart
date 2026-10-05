// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'sort_object.dart';

part 'pageable_object.g.dart';

@JsonSerializable()
class PageableObject {
  const PageableObject({
    this.offset,
    this.paged,
    this.sort,
    this.pageSize,
    this.pageNumber,
    this.unpaged,
  });

  factory PageableObject.fromJson(Map<String, Object?> json) =>
      _$PageableObjectFromJson(json);

  final int? offset;
  final bool? paged;
  final SortObject? sort;
  final int? pageSize;
  final int? pageNumber;
  final bool? unpaged;

  Map<String, Object?> toJson() => _$PageableObjectToJson(this);
}
