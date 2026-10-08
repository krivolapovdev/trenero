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

/// Drops every cache holding data of the signed in user.
///
/// Used when a session ends (logout, account deletion) so neither the memory of
/// the device nor the next session can show data of the previous user.
///
/// The tokens are removed by `AuthRepository.logout` and the preferences of the
/// device (the selected language) are intentionally kept: they do not belong to
/// the user that is signing out.
class CacheCleaner {
  new(this._ref);

  final Ref _ref;

  /// Clears the lists, images and provider states that outlive the session.
  ///
  /// Must be called once the pages of the session are gone: invalidating a
  /// provider that is still listened to rebuilds it right away, i.e. requests
  /// the API with the tokens that were just removed.
  void clearSessionCaches() {
    // The repositories keep their lists between two requests, without being
    // tied to the pages that read them.
    _ref.read(groupRepositoryProvider).clearCache();
    _ref.read(studentRepositoryProvider).clearCache();

    // Decoded images live in a cache owned by the painting binding.
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();

    // None of the providers below is auto disposed (Riverpod keeps providers
    // without `autoDispose` alive for the whole life of the container), so
    // their state has to be dropped explicitly.
    _ref.invalidate(groupListControllerProvider);
    _ref.invalidate(groupStudentsProvider);
    _ref.invalidate(groupLessonsProvider);

    _ref.invalidate(studentListControllerProvider);
    _ref.invalidate(studentLessonsProvider);
    _ref.invalidate(studentPaymentsControllerProvider);
    _ref.invalidate(studentFilterControllerProvider);

    _ref.invalidate(transactionsControllerProvider);
    _ref.invalidate(paymentMetricsControllerProvider);
    _ref.invalidate(selectedMetricIndexProvider);
  }
}
