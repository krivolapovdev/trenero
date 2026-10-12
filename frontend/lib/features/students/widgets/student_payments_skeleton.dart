import 'package:flutter/material.dart';
import 'package:phone/core/widgets/transaction_list_view.dart';
import 'package:phone/features/finance/widgets/transaction_list_dummy_transactions.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentPaymentsSkeleton extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final String? overrideTitle;
  final String? emptyText;

  const new({
    super.key,
    required this.onRefresh,
    this.overrideTitle,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) => Skeletonizer(
    ignorePointers: false,
    child: TransactionListView(
      transactions: transactionListDummyTransactions,
      isLoading: true,
      onRefresh: onRefresh,
      overrideTitle: overrideTitle,
      emptyText: emptyText,
    ),
  );
}
