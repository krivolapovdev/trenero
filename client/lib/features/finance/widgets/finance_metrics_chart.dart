import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/features/finance/controllers/payment_metrics_controller.dart';
import 'package:phone/features/finance/widgets/chart_skeleton.dart';
import 'package:phone/features/finance/widgets/metrics_message.dart';
import 'package:phone/features/finance/widgets/profit_line_chart.dart';
import 'package:phone/i18n/strings.g.dart';

class FinanceMetricsChart extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(paymentMetricsControllerProvider);
    final selectedIndex = ref.watch(selectedMetricIndexProvider);

    return metricsAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return MetricsMessage(message: context.t.noData);
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
      error: (error, stackTrace) => MetricsMessage(
        message: context.t.errorLoadingData(
          error: error.userMessage(context.t),
        ),
      ),
    );
  }
}
