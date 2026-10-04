// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pageable_object.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageableObject _$PageableObjectFromJson(Map<String, dynamic> json) =>
    PageableObject(
      offset: (json['offset'] as num?)?.toInt(),
      paged: json['paged'] as bool?,
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      sort: json['sort'] == null
          ? null
          : SortObject.fromJson(json['sort'] as Map<String, dynamic>),
      unpaged: json['unpaged'] as bool?,
    );

Map<String, dynamic> _$PageableObjectToJson(PageableObject instance) =>
    <String, dynamic>{
      'offset': instance.offset,
      'paged': instance.paged,
      'pageNumber': instance.pageNumber,
      'pageSize': instance.pageSize,
      'sort': instance.sort,
      'unpaged': instance.unpaged,
    };
