// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'pageable_object.dart';
import 'sort_object.dart';
import 'transaction_response.dart';

part 'page_transaction_response.g.dart';

@JsonSerializable()
class PageTransactionResponse {
  const PageTransactionResponse({
    this.totalPages,
    this.totalElements,
    this.size,
    this.content,
    this.number,
    this.first,
    this.last,
    this.numberOfElements,
    this.pageable,
    this.sort,
    this.empty,
  });

  factory PageTransactionResponse.fromJson(Map<String, Object?> json) =>
      _$PageTransactionResponseFromJson(json);

  final int? totalPages;
  final int? totalElements;
  final int? size;
  final List<TransactionResponse>? content;
  final int? number;
  final bool? first;
  final bool? last;
  final int? numberOfElements;
  final PageableObject? pageable;
  final SortObject? sort;
  final bool? empty;

  Map<String, Object?> toJson() => _$PageTransactionResponseToJson(this);
}
