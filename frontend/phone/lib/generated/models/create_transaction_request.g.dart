// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTransactionRequest _$CreateTransactionRequestFromJson(
  Map<String, dynamic> json,
) => CreateTransactionRequest(
  amount: json['amount'] as num,
  type: TransactionType.fromJson(json['type'] as String),
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$CreateTransactionRequestToJson(
  CreateTransactionRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'date': instance.date.toIso8601String(),
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'INCOME',
  TransactionType.expense: 'EXPENSE',
  TransactionType.$unknown: r'$unknown',
};
