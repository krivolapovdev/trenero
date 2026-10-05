// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageTransactionResponse _$PageTransactionResponseFromJson(
  Map<String, dynamic> json,
) => PageTransactionResponse(
  totalElements: (json['totalElements'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  size: (json['size'] as num?)?.toInt(),
  content: (json['content'] as List<dynamic>?)
      ?.map((e) => TransactionResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  number: (json['number'] as num?)?.toInt(),
  first: json['first'] as bool?,
  last: json['last'] as bool?,
  numberOfElements: (json['numberOfElements'] as num?)?.toInt(),
  sort: json['sort'] == null
      ? null
      : SortObject.fromJson(json['sort'] as Map<String, dynamic>),
  pageable: json['pageable'] == null
      ? null
      : PageableObject.fromJson(json['pageable'] as Map<String, dynamic>),
  empty: json['empty'] as bool?,
);

Map<String, dynamic> _$PageTransactionResponseToJson(
  PageTransactionResponse instance,
) => <String, dynamic>{
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'size': instance.size,
  'content': instance.content,
  'number': instance.number,
  'first': instance.first,
  'last': instance.last,
  'numberOfElements': instance.numberOfElements,
  'sort': instance.sort,
  'pageable': instance.pageable,
  'empty': instance.empty,
};
