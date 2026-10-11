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
  DateTime get _defaultFrom =>
      DateTime.now().subtract(const Duration(days: 365));

  DateTime get _defaultTo => DateTime.now();
  final String studentId;

  new(this.studentId);

  @override
  FutureOr<List<TransactionResponse>> build() async {
    final repository = ref.read(studentRepositoryProvider);

    return repository.getStudentPayments(
      studentId: studentId,
      from: _defaultFrom,
      to: _defaultTo,
    );
  }

  Future<void> refresh({DateTime? from, DateTime? to}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(studentRepositoryProvider);
      return repository.getStudentPayments(
        studentId: studentId,
        from: from ?? _defaultFrom,
        to: to ?? _defaultTo,
      );
    });
  }

  Future<void> filterByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(studentRepositoryProvider);
      return repository.getStudentPayments(
        studentId: studentId,
        from: from,
        to: to,
      );
    });
  }
}
