import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/students/controllers/update_student_controller.dart';
import 'package:phone/features/students/widgets/student_form_sheet.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class EditStudentBottomSheet extends ConsumerStatefulWidget {
  final StudentSummaryResponse student;

  const new({super.key, required this.student});

  @override
  ConsumerState<EditStudentBottomSheet> createState() =>
      _EditStudentBottomSheetState();
}

class _EditStudentBottomSheetState
    extends ConsumerState<EditStudentBottomSheet> {
  Future<void> _onUpdate({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
  }) async {
    final success = await ref
        .read(updateStudentControllerProvider.notifier)
        .updateStudent(
          studentId: widget.student.id,
          fullName: fullName,
          birthdate: birthdate,
          phone: phone,
          note: note,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final state = ref.read(updateStudentControllerProvider);
      final error = state.error;
      if (error != null) {
        AppSnackBar.show(context, 'Error: $error', SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(updateStudentControllerProvider).isLoading;
    final student = widget.student;

    return StudentFormSheet(
      title: context.t.students.editStudent,
      submitLabel: context.t.update,
      submitIcon: Icons.check,
      isLoading: isLoading,
      initialFullName: student.fullName,
      initialBirthdate: student.birthdate,
      initialPhone: student.phone,
      initialNote: student.note,
      onSubmit: _onUpdate,
    );
  }
}
