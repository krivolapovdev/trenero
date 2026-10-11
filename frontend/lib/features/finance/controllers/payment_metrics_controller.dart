import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:phone/features/finance/repositories/metric_repository.dart';
import 'package:phone/generated/models/metric_scope.dart';
import 'package:phone/generated/models/payment_metric_response.dart';

final paymentMetricsControllerProvider =
    AsyncNotifierProvider<
      PaymentMetricsController,
      List<PaymentMetricResponse>
    >(PaymentMetricsController.new);

class PaymentMetricsController
    extends AsyncNotifier<List<PaymentMetricResponse>> {
  @override
  FutureOr<List<PaymentMetricResponse>> build() async {
    final repository = ref.watch(metricRepositoryProvider);

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 6, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    return repository.getPaymentStatistics(
      startDate: startDate,
      endDate: endDate,
      scope: MetricScope.month,
    );
  }

  Future<void> loadMetrics({DateTime? startDate, DateTime? endDate}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(metricRepositoryProvider);
      final now = DateTime.now();
      final start = startDate ?? DateTime(now.year, now.month - 6, 1);
      final end = endDate ?? DateTime(now.year, now.month + 1, 0);

      return repository.getPaymentStatistics(
        startDate: start,
        endDate: end,
        scope: MetricScope.month,
      );
    });
  }
}

/// Provider for managing selected chart index
final selectedMetricIndexProvider = StateProvider<int>((ref) => 0);
