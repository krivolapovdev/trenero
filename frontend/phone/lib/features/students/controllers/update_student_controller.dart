import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/features/students/controllers/create_student_controller.dart';
import 'package:phone/features/students/controllers/student_mutation_refresh.dart';
import 'package:phone/features/students/services/student_service.dart';

final updateStudentControllerProvider =
    AsyncNotifierProvider<UpdateStudentController, void>(
      UpdateStudentController.new,
    );

class UpdateStudentController extends AsyncNotifier<void> {
  /// `PATCH /api/v1/students/{studentId}` is handled by `StudentMapper` on the
  /// backend, which parses the birthdate with `LocalDate.parse`, so a plain
  /// `yyyy-MM-dd` value is required (an ISO date-time would fail).
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  @override
  FutureOr<void> build() {}

  Future<bool> updateStudent({
    required String studentId,
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final trimmedName = fullName.trim();
      if (trimmedName.isEmpty) {
        throw ArgumentError('Student name is required.');
      }

      final body = <String, dynamic>{
        'fullName': trimmedName,
        'birthdate': birthdate == null ? null : _isoDate.format(birthdate),
        'phone': blankToNull(phone),
        'note': blankToNull(note),
      };

      final service = ref.read(studentServiceProvider);
      await service.updateStudent(studentId: studentId, body: body);

      // The card of the student shows the edited fields, so the list has to
      // be reloaded.
      await refreshAfterStudentMutation(ref);
    });

    return !state.hasError;
  }
}
