import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionListPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(transactionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.finance.lastTransactions),
        elevation: 0,
      ),
      body: listState.when(
        data: (data) => TransactionListView(
          transactions: data.transactions,
          isLoadingMore: data.isLoadingMore,
          onRefresh: () =>
              ref.read(transactionsControllerProvider.notifier).refresh(),
          onFetchNextPage: () =>
              ref.read(transactionsControllerProvider.notifier).fetchNextPage(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error.toString(),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(transactionsControllerProvider.notifier).refresh(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
