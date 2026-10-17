import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/transaction_filter_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/widgets/transactions_retry.dart';
import 'package:phone/features/finance/widgets/transactions_skeleton.dart';

class TransactionListBody extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TransactionListBody> createState() =>
      _TransactionListBodyState();
}

class _TransactionListBodyState extends ConsumerState<TransactionListBody> {
  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(transactionsControllerProvider);
    final period = ref.watch(transactionFilterControllerProvider);
    final loadedTransactions = listState.value?.transactions ?? const [];
    final transactions = period.filter(loadedTransactions);

    final isRetry = listState.hasError && loadedTransactions.isEmpty;

    _loadMoreWhilePeriodIsEmpty(
      hasPeriod: period.isNotEmpty,
      isRetry: isRetry,
      isEmpty: transactions.isEmpty,
      hasMore: listState.value?.hasMore ?? false,
      isLoadingMore: listState.value?.isLoadingMore ?? false,
    );

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

  void _loadMoreWhilePeriodIsEmpty({
    required bool hasPeriod,
    required bool isRetry,
    required bool isEmpty,
    required bool hasMore,
    required bool isLoadingMore,
  }) {
    if (!hasPeriod || isRetry || !isEmpty || !hasMore || isLoadingMore) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ref.read(transactionsControllerProvider.notifier).fetchNextPage();
    });
  }
}
