import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/recent_transactions.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/finance/controllers/payment_metrics_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/finance/pages/transaction_list_page.dart';
import 'package:phone/features/finance/widgets/chart_skeleton.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/finance/widgets/profit_line_chart.dart';
import 'package:phone/i18n/strings.g.dart';

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
    builder: (context, ref, child) => CustomMaterialIndicator(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      onRefresh: () async {
        await Future.wait([
          ref.read(paymentMetricsControllerProvider.notifier).loadMetrics(),
          ref.read(transactionsControllerProvider.notifier).refresh(),
        ]);
      },
      child: const SingleChildScrollView(
        clipBehavior: Clip.none,
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [_FinanceMetricsChart(), _FinanceRecentTransactions()],
          ),
        ),
      ),
    ),
  );
}

class _FinanceMetricsChart extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(paymentMetricsControllerProvider);
    final selectedIndex = ref.watch(selectedMetricIndexProvider);

    return metricsAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return _MetricsMessage(message: context.t.noData);
        }

        return ProfitLineChart(
          data: data,
          selectedIndex: selectedIndex.clamp(0, data.length - 1),
          onIndexChanged: (index) {
            ref.read(selectedMetricIndexProvider.notifier).state = index;
          },
        );
      },
      loading: () => const ChartSkeleton(),
      error: (error, stackTrace) =>
          _MetricsMessage(message: context.t.errorLoadingData(error: error)),
    );
  }
}

class _FinanceRecentTransactions extends ConsumerWidget {
  const new();

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
    );
  }
}

class _MetricsMessage extends StatelessWidget {
  static const double _height = 200;

  final String message;

  const new({required this.message});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _height,
    child: Center(child: Text(message)),
  );
}
