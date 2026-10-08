import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
import 'package:phone/generated/models/create_transaction_request.dart';
import 'package:phone/generated/models/page_transaction_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/generated/transaction_controller/transaction_controller_client.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final service = ref.watch(transactionServiceProvider);
  return TransactionRepository(service);
});

class TransactionRepository {
  final TransactionControllerClient _client;

  new(this._client);

  Future<PageTransactionResponse> getTransactionsByPage({
    int page = 1,
    int size = 20,
  }) async => await _client.getPaginatedTransactions(page: page, size: size);

  Future<TransactionResponse> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> body,
  }) async =>
      await _client.updateTransaction(transactionId: transactionId, body: body);

  Future<void> deleteTransaction(String transactionId) async =>
      await _client.deleteTransaction(transactionId: transactionId);

  Future<void> createTransaction({
    required TransactionType type,
    required double amount,
    required DateTime date,
  }) async {
    await _client.createTransaction(
      body: CreateTransactionRequest(type: type, amount: amount, date: date),
    );
  }
}
