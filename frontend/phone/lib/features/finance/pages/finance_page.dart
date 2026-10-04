import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/finance/controllers/payment_metrics_controller.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/profit_line_chart.dart';
import 'package:phone/features/finance/widgets/recent_transactions.dart';

class FinancePage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.monetization_on_outlined,
    super.selectedIcon = Icons.monetization_on,
  });

  @override
  List<Widget> actions(BuildContext context) => [
    IconButton(
      icon: const Icon(FluentIcons.savings_24_regular),
      onPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateTransactionBottomSheet(),
      ),
    ),
    const SizedBox(width: 8),
  ];

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, child) {
      final metricsAsync = ref.watch(paymentMetricsControllerProvider);
      final selectedIndex = ref.watch(selectedMetricIndexProvider);

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [
              metricsAsync.when(
                data: (data) {
                  if (data.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('Нет данных')),
                    );
                  }

                  final safeIndex = selectedIndex.clamp(0, data.length - 1);

                  return ProfitLineChart(
                    data: data,
                    selectedIndex: safeIndex,
                    onIndexChanged: (index) {
                      ref.read(selectedMetricIndexProvider.notifier).state =
                          index;
                    },
                  );
                },
                loading: () => const SizedBox(
                  height: 380,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => SizedBox(
                  height: 200,
                  child: Center(child: Text('Ошибка загрузки данных: $error')),
                ),
              ),
              const RecentTransactions(),
            ],
          ),
        ),
      );
    },
  );
}
