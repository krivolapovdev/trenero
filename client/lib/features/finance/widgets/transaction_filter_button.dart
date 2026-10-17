import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/finance/controllers/transaction_filter_controller.dart';
import 'package:phone/features/finance/widgets/transaction_period_filter_bottom_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

class TransactionFilterButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(transactionFilterControllerProvider).isNotEmpty;

    return IconButton(
      tooltip: context.t.finance.filter.title,
      icon: Badge(
        smallSize: 10,
        isLabelVisible: isActive,
        child: const Icon(FluentIcons.filter_28_regular),
      ),
      onPressed: () => AppBottomSheet.show(
        context: context,
        child: const TransactionPeriodFilterBottomSheet(),
      ),
    );
  }
}
