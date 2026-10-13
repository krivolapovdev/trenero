import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/constants/app_date_formats.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/features/students/controllers/student_mutation_refresh.dart';
import 'package:phone/features/students/repositories/student_repository.dart';

final updateStudentControllerProvider =
    AsyncNotifierProvider<UpdateStudentController, void>(
      UpdateStudentController.new,
    );

class UpdateStudentController extends AsyncNotifier<void> {
  static final DateFormat _isoDate = DateFormat(AppDateFormats.isoDate);

  @override
  FutureOr<void> build() {}

  Future<bool> updateStudent({
    required String studentId,
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

      final body = <String, dynamic>{
        'fullName': trimmedName,
        'birthdate': birthdate == null ? null : _isoDate.format(birthdate),
        'phone': phone.trimmedOrNull,
        'note': note.trimmedOrNull,
        'free': free,
      };

      final repository = ref.read(studentRepositoryProvider);
      await repository.updateStudent(studentId: studentId, body: body);

      await refreshAfterStudentMutation(ref);
    });

    return !state.hasError;
  }
}
