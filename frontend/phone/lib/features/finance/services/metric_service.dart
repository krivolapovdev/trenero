import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/api_provider.dart';
import 'package:phone/generated/metric_controller/metric_controller_client.dart';

final metricServiceProvider = Provider<MetricControllerClient>((ref) {
  final api = ref.watch(apiProvider);
  return MetricControllerClient(api);
});
