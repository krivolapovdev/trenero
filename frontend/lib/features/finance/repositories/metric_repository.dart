import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/services/metric_service.dart';
import 'package:phone/generated/metric_controller/metric_controller_client.dart';
import 'package:phone/generated/models/metric_scope.dart';
import 'package:phone/generated/models/payment_metric_response.dart';

final metricRepositoryProvider = Provider<MetricRepository>((ref) {
  final service = ref.watch(metricServiceProvider);
  return MetricRepository(service);
});

class MetricRepository {
  final MetricControllerClient _service;

  new(this._service);

  Future<List<PaymentMetricResponse>> getPaymentStatistics({
    required DateTime startDate,
    required DateTime endDate,
    MetricScope scope = MetricScope.month,
  }) => _service.getPaymentStatistics(
    startDate: startDate,
    endDate: endDate,
    scope: scope,
  );
}
