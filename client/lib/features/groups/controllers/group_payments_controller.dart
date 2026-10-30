import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_mutation_refresh.dart';
import 'package:phone/features/groups/models/group_student_payment.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final groupPaymentsControllerProvider =
    AsyncNotifierProvider<GroupPaymentsController, void>(
      GroupPaymentsController.new,
    );

class GroupPaymentsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> createPayments({
    required String groupId,
    required DateTime paymentDate,
    required List<GroupStudentPaymentItem> payments,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final studentRepo = ref.read(studentRepositoryProvider);

      for (final payment in payments) {
        await studentRepo.createStudentPayment(
          studentId: payment.studentId,
          amount: payment.amount,
          date: paymentDate,
          paidUntil: payment.paidUntil,
        );
      }

      await refreshAfterGroupPaymentsMutation(
        ref,
        groupId: groupId,
        studentIds: payments.map((p) => p.studentId),
      );
    });

    return !state.hasError;
  }
}
