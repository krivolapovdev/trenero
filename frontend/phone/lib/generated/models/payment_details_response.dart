// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'payment_details_response.g.dart';

@JsonSerializable()
class PaymentDetailsResponse {
  const PaymentDetailsResponse({required this.detailsType});

  factory PaymentDetailsResponse.fromJson(Map<String, Object?> json) =>
      _$PaymentDetailsResponseFromJson(json);

  final String detailsType;

  Map<String, Object?> toJson() => _$PaymentDetailsResponseToJson(this);
}
