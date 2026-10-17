import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/payment_metrics_controller.dart';
import 'package:phone/features/finance/controllers/transaction_list_controller.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final cacheCleanerProvider = Provider<CacheCleaner>(CacheCleaner.new);

class CacheCleaner {
  new(this._ref);

  final Ref _ref;

  void clearSessionCaches() {
    _ref.read(groupRepositoryProvider).clearCache();
    _ref.read(studentRepositoryProvider).clearCache();

    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();

    _ref
      ..invalidate(groupListControllerProvider)
      ..invalidate(groupStudentsProvider)
      ..invalidate(groupLessonsProvider)
      ..invalidate(studentListControllerProvider)
      ..invalidate(studentLessonsProvider)
      ..invalidate(studentPaymentsControllerProvider)
      ..invalidate(studentFilterControllerProvider)
      ..invalidate(transactionsControllerProvider)
      ..invalidate(paymentMetricsControllerProvider)
      ..invalidate(selectedMetricIndexProvider);
  }
}
