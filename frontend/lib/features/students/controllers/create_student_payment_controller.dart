import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/finance/controllers/transaction_mutation_refresh.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final createStudentPaymentControllerProvider =
    AsyncNotifierProvider<CreateStudentPaymentController, void>(
      CreateStudentPaymentController.new,
    );

class CreateStudentPaymentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Creates an income transaction with student payment details for [studentId].
  Future<bool> saveStudentPayment({
    required String studentId,
    required double amount,
    required DateTime date,
    required DateTime paidUntil,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(studentRepositoryProvider)
          .createStudentPayment(
            studentId: studentId,
            amount: amount,
            date: date,
            paidUntil: paidUntil,
          );

      ref.invalidate(studentPaymentsControllerProvider(studentId));

      await ref
          .read(studentListControllerProvider.notifier)
          .getAllStudents(forceRefresh: true);

      await refreshAfterTransactionMutation(ref, action: 'creating');
    });

    return !state.hasError;
  }
}
