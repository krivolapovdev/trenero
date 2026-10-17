import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/empty_transactions.dart';
import 'package:phone/core/widgets/grouped_transactions.dart';
import 'package:phone/core/widgets/recent_transactions_header.dart';
import 'package:phone/core/widgets/transactions_error.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RecentTransactions extends StatelessWidget {
  static const int _maxRecentItems = 5;

  final AsyncValue<List<TransactionResponse>> asyncTransactions;
  final VoidCallback? onSeeAllPressed;
  final VoidCallback? onAddPressed;
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
    VoidCallback? onAddPressed,
    VoidCallback? onAdd,
  }) : onAddPressed = onAddPressed ?? onAdd;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    padding: const EdgeInsets.only(top: AppSpacing.sm),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecentTransactionsHeader(
          isLoading: asyncTransactions.isLoading,
          onSeeAllPressed: onSeeAllPressed,
        ),
        asyncTransactions.when(
          data: (transactions) {
            final recentItems = transactions.take(_maxRecentItems).toList();

            if (recentItems.isEmpty) return const EmptyTransactions();

            return GroupedTransactions(
              transactions: recentItems,
              overrideTitle: overrideTitle,
            );
          },
          loading: () => Skeletonizer(
            ignorePointers: false,
            child: GroupedTransactions(
              transactions: asyncTransactions.value ?? _dummyTransactions,
              overrideTitle: overrideTitle,
              isTappable: false,
            ),
          ),
          error: (error, stack) => TransactionsError(error: error),
        ),
        if (onAddPressed != null)
          Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.xl,
              bottom: AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Skeletonizer(
                enabled: asyncTransactions.isLoading,
                child: TextButton(
                  onPressed: onAddPressed,
                  child: Text(
                    context.t.add,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
