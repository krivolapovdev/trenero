import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/features/students/controllers/student_mutation_refresh.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
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
        throw const ValidationException(
          'Student name is required.',
          code: AppErrorCode.studentNameRequired,
        );
      }

      final request = CreateStudentRequest(
        fullName: trimmedName,
        birthdate: birthdate,
        phone: phone.trimmedOrNull,
        note: note.trimmedOrNull,
        free: free,
      );

      final repository = ref.read(studentRepositoryProvider);
      await repository.createStudent(request);

      await refreshAfterStudentMutation(ref);
    });

    return !state.hasError;
  }
}
