import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/recent_transactions.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/pages/transaction_list_page.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';

class FinanceRecentTransactions extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsControllerProvider);
    final transactionsAsync = transactionsState.whenData(
      (state) => state.transactions,
    );

    return RecentTransactions(
      asyncTransactions: transactionsAsync,
      onSeeAllPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const TransactionListPage()),
      ),
      onAddPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateTransactionBottomSheet(),
      ),
    );
  }
}
