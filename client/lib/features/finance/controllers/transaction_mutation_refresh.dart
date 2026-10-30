import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/payment_metrics_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/groups/controllers/group_report_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';

Future<void> refreshAfterTransactionMutation(
  Ref ref, {
  required String action,
  String? studentId,
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

  if (studentId == null) return;

  ref
    ..invalidate(studentPaymentsControllerProvider(studentId))
    ..invalidate(groupStudentsProvider)
    ..invalidate(groupReportProvider);

  await ref
      .read(studentListControllerProvider.notifier)
      .getAllStudents(forceRefresh: true);
}
