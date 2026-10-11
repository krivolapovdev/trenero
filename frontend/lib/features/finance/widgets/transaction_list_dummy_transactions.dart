import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';

final List<TransactionResponse> transactionListDummyTransactions = List.generate(
  10,
  (index) => TransactionResponse(
    id: 'placeholder-$index',
    amount: 1000,
    date: DateTime.now(),
    type: TransactionType.values.first,
    createdAt: DateTime.now(),
  ),
);
