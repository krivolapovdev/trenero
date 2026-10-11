import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/features/finance/controllers/transaction_mutation_refresh.dart';
import 'package:phone/features/finance/repositories/transaction_repository.dart';
import 'package:phone/generated/models/transaction_response.dart';

final updateTransactionControllerProvider =
    AsyncNotifierProvider<UpdateTransactionController, void>(
      UpdateTransactionController.new,
    );

class UpdateTransactionController extends AsyncNotifier<void> {
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  @override
  FutureOr<void> build() {}

  Future<TransactionResponse?> updateTransaction({
    required String transactionId,
    required num amount,
    required DateTime date,
  }) async {
    TransactionResponse? updatedTransaction;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      updatedTransaction = await ref
          .read(transactionRepositoryProvider)
          .updateTransaction(
            transactionId: transactionId,
            body: {'amount': amount, 'date': _isoDate.format(date)},
          );

      await refreshAfterTransactionMutation(ref, action: 'updating');
    });

    return state.hasError ? null : updatedTransaction;
  }
}
