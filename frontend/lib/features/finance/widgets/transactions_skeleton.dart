import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/widgets/transaction_list_dummy_transactions.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionsSkeleton extends ConsumerWidget {
  final AsyncValue<TransactionsState> listState;
  final List<TransactionResponse> transactions;

  const new({super.key, required this.listState, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = listState.isLoading;
    final displayTransactions = isLoading && transactions.isEmpty
        ? transactionListDummyTransactions
        : transactions;

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: TransactionListView(
        transactions: displayTransactions,
        isLoading: isLoading,
        isLoadingMore: listState.value?.isLoadingMore ?? false,
        onRefresh: () =>
            ref.read(transactionsControllerProvider.notifier).refresh(),
        onFetchNextPage: () =>
            ref.read(transactionsControllerProvider.notifier).fetchNextPage(),
      ),
    );
  }
}
