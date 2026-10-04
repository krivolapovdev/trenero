// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/metric_scope.dart';
import '../models/payment_metric_response.dart';

part 'metric_controller_client.g.dart';

@RestApi()
abstract class MetricControllerClient {
  factory MetricControllerClient(Dio dio, {String? baseUrl}) =
      _MetricControllerClient;

  @GET('/api/v1/metrics/payments')
  Future<List<PaymentMetricResponse>> getPaymentStatistics({
    @Query('startDate') required DateTime startDate,
    @Query('endDate') required DateTime endDate,
    @Query('scope') MetricScope? scope = MetricScope.month,
  });
}
