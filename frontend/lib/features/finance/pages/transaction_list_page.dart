import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

final List<TransactionResponse> _dummyTransactions = List.generate(
  10,
  (index) => TransactionResponse(
    id: 'placeholder-$index',
    amount: 1000,
    date: DateTime.now(),
    type: TransactionType.values.first,
    createdAt: DateTime.now(),
  ),
);

class TransactionListPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: Text(context.t.finance.lastTransactions),
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      actions: [
        IconButton(
          icon: const Icon(FluentIcons.savings_24_regular),
          tooltip: context.t.finance.createTransaction,
          onPressed: () => AppBottomSheet.show(
            context: context,
            child: const CreateTransactionBottomSheet(),
          ),
        ),
        const SizedBox(width: 8),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomRounded,
      ),
    ),
    body: const _TransactionListBody(),
  );
}

class _TransactionListBody extends ConsumerWidget {
  const new();

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
          ? _TransactionsRetry(error: listState.error)
          : _TransactionsSkeleton(
              listState: listState,
              transactions: transactions,
            ),
    );
  }
}

class _TransactionsRetry extends ConsumerWidget {
  final Object? error;

  const new({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: '$error',
    messageColor: Theme.of(context).colorScheme.error,
    scrollable: true,
    onRetry: () => ref.read(transactionsControllerProvider.notifier).refresh(),
  );
}

class _TransactionsSkeleton extends ConsumerWidget {
  final AsyncValue<TransactionsState> listState;
  final List<TransactionResponse> transactions;

  const new({required this.listState, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = listState.isLoading;
    final displayTransactions = isLoading && transactions.isEmpty
        ? _dummyTransactions
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
