// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_payment_details_request.g.dart';

@JsonSerializable()
class CreatePaymentDetailsRequest {
  const CreatePaymentDetailsRequest({required this.detailsType});

  factory CreatePaymentDetailsRequest.fromJson(Map<String, Object?> json) =>
      _$CreatePaymentDetailsRequestFromJson(json);

  final String detailsType;

  Map<String, Object?> toJson() => _$CreatePaymentDetailsRequestToJson(this);
}
