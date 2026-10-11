import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/pages/transaction_page.dart';
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
    clipBehavior: Clip.antiAlias,
    padding: const EdgeInsets.only(top: AppSpacing.lg),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Skeletonizer(
            enabled: asyncTransactions.isLoading,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.t.finance.lastTransactions,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                if (onSeeAllPressed != null)
                  TextButton(
                    onPressed: onSeeAllPressed,
                    child: Text(
                      context.t.all,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
        asyncTransactions.when(
          data: (transactions) {
            final recentItems = transactions.take(5).toList();

            if (recentItems.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxl,
                ),
                child: Center(
                  child: Text(
                    context.t.noTransactions,
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                ),
              );
            }

            return _buildGroupedTransactions(context, recentItems);
          },
          loading: () => Skeletonizer(
            ignorePointers: false,
            child: _buildGroupedTransactions(
              context,
              asyncTransactions.value ?? _dummyTransactions,
              isTappable: false,
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
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
    List<TransactionResponse> transactions, {
    bool isTappable = true,
  }) {
    final groupedTransactions =
        TransactionDateFormatter.groupTransactionsByDate(transactions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedTransactions.entries.expand((entry) {
        final dateHeader = TransactionDateFormatter.formatDateHeader(entry.key);
        final items = entry.value;

        return [
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.sm,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
            ),
            child: Text(
              dateHeader,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ...items.map(
            (tx) => TransactionTile(
              transaction: tx,
              overrideTitle: overrideTitle,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              borderRadius: BorderRadius.zero,
              onTap: isTappable
                  ? () => _openTransactionPage(context, tx)
                  : null,
            ),
          ),
        ];
      }).toList(),
    );
  }

  void _openTransactionPage(
    BuildContext context,
    TransactionResponse transaction,
  ) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TransactionPage(
        transaction: transaction,
        overrideTitle: overrideTitle,
      ),
    ),
  );
}
