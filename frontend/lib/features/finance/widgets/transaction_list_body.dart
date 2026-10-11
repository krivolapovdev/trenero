import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/widgets/transactions_retry.dart';
import 'package:phone/features/finance/widgets/transactions_skeleton.dart';

class TransactionListBody extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(transactionsControllerProvider);
    final transactions = listState.value?.transactions ?? const [];

    final isRetry = listState.hasError && transactions.isEmpty;

    return CustomMaterialIndicator(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      onRefresh: () async {
        await ref.read(transactionsControllerProvider.notifier).refresh();
      },
      child: isRetry
          ? TransactionsRetry(error: listState.error)
          : TransactionsSkeleton(
              listState: listState,
              transactions: transactions,
            ),
    );
  }
}
