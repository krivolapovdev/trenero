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
      type: TransactionType.fromJson(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      studentPayment: json['studentPayment'] == null
          ? null
          : TransactionStudentPaymentResponse.fromJson(
              json['studentPayment'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TransactionResponseToJson(
  TransactionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'studentPayment': instance.studentPayment,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'INCOME',
  TransactionType.expense: 'EXPENSE',
  TransactionType.$unknown: r'$unknown',
};
