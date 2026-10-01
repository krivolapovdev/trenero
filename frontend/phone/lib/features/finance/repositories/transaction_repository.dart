import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/services/transaction_service.dart';
import 'package:phone/generated/models/page_transaction_response.dart';
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
  }) async => await _client.getPaginatedTransactionsWithStudentPayment(
    page: page,
    size: size,
  );
}
