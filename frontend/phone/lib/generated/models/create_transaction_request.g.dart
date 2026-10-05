// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTransactionRequest _$CreateTransactionRequestFromJson(
  Map<String, dynamic> json,
) => CreateTransactionRequest(
  amount: json['amount'] as num,
  date: DateTime.parse(json['date'] as String),
  type: TransactionType.fromJson(json['type'] as String),
  paymentDetails: json['paymentDetails'] == null
      ? null
      : CreateStudentPaymentDetailsRequest.fromJson(
          json['paymentDetails'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$CreateTransactionRequestToJson(
  CreateTransactionRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'paymentDetails': instance.paymentDetails,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'INCOME',
  TransactionType.expense: 'EXPENSE',
  TransactionType.$unknown: r'$unknown',
};
