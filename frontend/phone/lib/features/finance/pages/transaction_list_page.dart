import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/utils/transaction_date_formatter.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionList extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionsControllerProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(transactionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.finance.lastTransactions),
        elevation: 0,
      ),
      body: listState.when(
        data: (data) {
          if (data.transactions.isEmpty) {
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(transactionsControllerProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Нет операций',
                      style: TextStyle(color: Color(0xFF8E8E93)),
                    ),
                  ),
                ],
              ),
            );
          }

          final groupedTransactions =
              TransactionDateFormatter.groupTransactionsByDate(
                data.transactions,
              );

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(transactionsControllerProvider.notifier).refresh(),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                ...groupedTransactions.entries.expand((entry) {
                  final dateHeader = TransactionDateFormatter.formatDateHeader(
                    entry.key,
                    context,
                  );
                  final items = entry.value;

                  return [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Text(
                        dateHeader,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ...items.map(
                            (tx) => TransactionTile(transaction: tx),
                          ),
                        ],
                      ),
                    ),
                  ];
                }),
                if (data.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
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
