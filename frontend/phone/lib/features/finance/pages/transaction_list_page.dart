import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TransactionListPage extends ConsumerWidget {
  const new({super.key});

  static final List<TransactionResponse> _dummyTransactions = List.generate(
    10,
    (index) => TransactionResponse(
      id: 'placeholder-$index',
      amount: 1000,
      date: DateTime.now(),
      type: TransactionType.values.first,
      createdAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(transactionsControllerProvider);
    final isLoading = listState.isLoading;
    final hasError = listState.hasError;
    final transactions = listState.value?.transactions ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.finance.lastTransactions),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () async {
          await ref.read(transactionsControllerProvider.notifier).refresh();
        },
        child: _buildBody(
          context,
          ref,
          listState,
          transactions,
          isLoading,
          hasError,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue listState,
    List<TransactionResponse> transactions,
    bool isLoading,
    bool hasError,
  ) {
    if (hasError && transactions.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${listState.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(transactionsControllerProvider.notifier)
                        .refresh(),
                    child: Text(context.t.repeat),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: TransactionListView(
        transactions: isLoading && transactions.isEmpty
            ? _dummyTransactions
            : transactions,
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
