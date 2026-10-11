import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/payment_metrics_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';

Future<void> refreshAfterTransactionMutation(
  Ref ref, {
  required String action,
}) async {
  await ref.read(transactionsControllerProvider.notifier).refresh();

  unawaited(
    ref
        .read(paymentMetricsControllerProvider.notifier)
        .loadMetrics()
        .catchError((error, _) {
          log('Error refreshing metrics after $action transaction: $error');
        }),
  );
}
