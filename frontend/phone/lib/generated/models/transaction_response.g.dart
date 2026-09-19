// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionResponse _$TransactionResponseFromJson(Map<String, dynamic> json) =>
    TransactionResponse(
      id: json['id'] as String,
      amount: json['amount'] as num,
      date: DateTime.parse(json['date'] as String),
      type: TransactionResponseType.fromJson(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TransactionResponseToJson(
  TransactionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'type': _$TransactionResponseTypeEnumMap[instance.type]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$TransactionResponseTypeEnumMap = {
  TransactionResponseType.income: 'INCOME',
  TransactionResponseType.expense: 'EXPENSE',
  TransactionResponseType.$unknown: r'$unknown',
};
