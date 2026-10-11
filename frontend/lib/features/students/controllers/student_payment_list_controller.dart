import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/generated/models/transaction_response.dart';

final studentPaymentsControllerProvider =
    AsyncNotifierProvider.family<
      StudentPaymentsController,
      List<TransactionResponse>,
      String
    >(StudentPaymentsController.new);

class StudentPaymentsController
    extends AsyncNotifier<List<TransactionResponse>> {
  final String studentId;

  new(this.studentId);

  @override
  FutureOr<List<TransactionResponse>> build() =>
      ref.read(studentRepositoryProvider).getStudentPayments(studentId);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(studentRepositoryProvider).getStudentPayments(studentId),
    );
  }
}
