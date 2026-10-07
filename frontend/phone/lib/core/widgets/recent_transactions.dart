import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/utils/transaction_date_formatter.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RecentTransactions extends StatelessWidget {
  final AsyncValue<List<TransactionResponse>> asyncTransactions;
  final VoidCallback? onSeeAllPressed;
  final String? overrideTitle;

  static TransactionResponse _tx(
    int id,
    num amount,
    TransactionType type, {
    int days = 0,
    int hours = 0,
  }) {
    final date = DateTime.now().subtract(Duration(days: days));
    return TransactionResponse(
      id: 'placeholder-$id',
      amount: amount,
      date: date,
      type: type,
      createdAt: date.subtract(Duration(hours: hours)),
    );
  }

  static final List<TransactionResponse> _dummyTransactions = [
    _tx(1, 1500, TransactionType.income),
    _tx(2, 900, TransactionType.expense, hours: 3),
    _tx(3, 2400, TransactionType.income, hours: 6),
    _tx(4, 750, TransactionType.expense, days: 1, hours: 2),
    _tx(5, 3200, TransactionType.income, days: 1, hours: 5),
  ];

  const new({
    super.key,
    required this.asyncTransactions,
    this.overrideTitle,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) => Container(
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
            if (onSeeAllPressed != null)
              FilledButton.icon(
                onPressed: onSeeAllPressed,
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
        asyncTransactions.when(
          data: (transactions) {
            final recentItems = transactions.take(5).toList();

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

            return _buildGroupedTransactions(context, recentItems);
          },
          loading: () => Skeletonizer(
            ignorePointers: false,
            child: _buildGroupedTransactions(context, _dummyTransactions),
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

  Widget _buildGroupedTransactions(
    BuildContext context,
    List<TransactionResponse> transactions,
  ) {
    final groupedTransactions =
        TransactionDateFormatter.groupTransactionsByDate(transactions);

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
          ...items.map(
            (tx) =>
                TransactionTile(transaction: tx, overrideTitle: overrideTitle),
          ),
        ];
      }).toList(),
    );
  }
}
