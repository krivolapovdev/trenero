import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/pages/transaction_list_page.dart';
import 'package:phone/features/finance/utils/transaction_date_formatter.dart';
import 'package:phone/i18n/strings.g.dart';

class RecentTransactions extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsControllerProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.t.finance.lastTransactions,
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransactionList(),
                  ),
                ),
                iconAlignment: IconAlignment.end,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8DEF8),
                  foregroundColor: const Color(0xFF1D192B),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                label: Text(context.t.all),
                icon: const Icon(Icons.chevron_right, size: 18),
              ),
            ],
          ),
          state.when(
            data: (data) {
              final recentItems = data.transactions.take(5).toList();

              if (recentItems.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'Нет операций',
                      style: TextStyle(color: Color(0xFF8E8E93)),
                    ),
                  ),
                );
              }

              final groupedTransactions =
                  TransactionDateFormatter.groupTransactionsByDate(recentItems);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groupedTransactions.entries.expand((entry) {
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
                    ...items.map((tx) => TransactionTile(transaction: tx)),
                  ];
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  error.toString(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
