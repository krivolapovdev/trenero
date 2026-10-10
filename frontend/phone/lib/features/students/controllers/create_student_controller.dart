import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_mutation_refresh.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/create_student_request.dart';

final createStudentControllerProvider =
    AsyncNotifierProvider<CreateStudentController, void>(
      CreateStudentController.new,
    );

class CreateStudentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> saveStudent({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
    required bool free,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final trimmedName = fullName.trim();
      if (trimmedName.isEmpty) {
        throw ArgumentError('Student name is required.');
      }

      final request = CreateStudentRequest(
        fullName: trimmedName,
        birthdate: birthdate,
        phone: blankToNull(phone),
        note: blankToNull(note),
        free: free,
      );

      final service = ref.read(studentServiceProvider);
      await service.createStudent(body: request);

      // The new student has to appear in the list the cards are drawn from.
      await refreshAfterStudentMutation(ref);
    });

    return !state.hasError;
  }
}

/// Trims [value] and returns `null` when nothing is left.
String? blankToNull(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
