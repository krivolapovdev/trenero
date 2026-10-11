import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/delete_confirmation_sheet.dart';
import 'package:phone/features/students/controllers/delete_student_controller.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Asks for confirmation before deleting [student].
///
/// Pops with `true` when the student was deleted. The caller is the one that
/// leaves the page of the student, so this sheet only reports the outcome.
class DeleteStudentBottomSheet extends ConsumerWidget {
  final StudentSummaryResponse student;

  const new({super.key, required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DeleteConfirmationSheet(
    title: context.t.students.deleteStudent,
    message: context.t.students.deleteStudentMessage,
    delete: () async {
      final controller = deleteStudentControllerProvider;

      final success = await ref
          .read(controller.notifier)
          .deleteStudent(student.id);

      if (success) return null;

      return ref.read(controller).error?.toString();
    },
  );
}
