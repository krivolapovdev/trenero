import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/repositories/transaction_repository.dart';
import 'package:phone/generated/models/page_transaction_response.dart';

final recentTransactionsControllerProvider =
    AsyncNotifierProvider<
      RecentTransactionsController,
      PageTransactionResponse
    >(RecentTransactionsController.new);

class RecentTransactionsController
    extends AsyncNotifier<PageTransactionResponse> {
  @override
  FutureOr<PageTransactionResponse> build() => _fetchRecentTransactions();

  Future<PageTransactionResponse> _fetchRecentTransactions() async {
    final repository = ref.read(transactionRepositoryProvider);
    return await repository.getTransactionsByPage(page: 1, size: 5);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRecentTransactions());
  }
}
