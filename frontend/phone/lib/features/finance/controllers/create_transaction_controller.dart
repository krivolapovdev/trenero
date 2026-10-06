import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/payment_metrics_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/repositories/transaction_repository.dart';
import 'package:phone/generated/models/transaction_type.dart';

final createTransactionControllerProvider =
    AsyncNotifierProvider<CreateTransactionController, void>(
      CreateTransactionController.new,
    );

class CreateTransactionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> saveTransaction({
    required TransactionType type,
    required double amount,
    required DateTime date,
  }) async {
    final transactionRepository = ref.read(transactionRepositoryProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await transactionRepository.createTransaction(
        type: type,
        amount: amount,
        date: date,
      );

      await ref.read(transactionsControllerProvider.notifier).refresh();
    });

    if (!state.hasError) {
      unawaited(
        ref
            .read(paymentMetricsControllerProvider.notifier)
            .loadMetrics()
            .catchError((error, _) {
              log(
                'Error refreshing metrics after creating transaction: $error',
              );
            }),
      );
    }

    return !state.hasError;
  }
}
