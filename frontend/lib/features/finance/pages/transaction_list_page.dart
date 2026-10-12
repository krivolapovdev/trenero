import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/transaction_filter_button.dart';
import 'package:phone/features/finance/widgets/transaction_list_body.dart';
import 'package:phone/i18n/strings.g.dart';

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
        const TransactionFilterButton(),

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
    body: const TransactionListBody(),
  );
}
