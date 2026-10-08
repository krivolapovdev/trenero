import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/transaction_mutation_refresh.dart';
import 'package:phone/features/finance/repositories/transaction_repository.dart';

final deleteTransactionControllerProvider =
    AsyncNotifierProvider<DeleteTransactionController, void>(
      DeleteTransactionController.new,
    );

class DeleteTransactionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteTransaction(String transactionId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionRepositoryProvider)
          .deleteTransaction(transactionId);

      await refreshAfterTransactionMutation(ref, action: 'deleting');
    });

    return !state.hasError;
  }
}
