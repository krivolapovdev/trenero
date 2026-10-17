import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/delete_confirmation_sheet.dart';
import 'package:phone/features/students/controllers/student_lesson_mutation_controller.dart';
import 'package:phone/i18n/strings.g.dart';

class DeleteStudentLessonBottomSheet extends ConsumerWidget {
  final String lessonId;
  final String studentId;

  const new({super.key, required this.lessonId, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DeleteConfirmationSheet(
    title: context.t.lessons.deleteLesson,
    message: context.t.lessons.deleteLessonMessage,
    delete: () async {
      final controller = studentLessonMutationControllerProvider;

      final success = await ref
          .read(controller.notifier)
          .deleteStudentLesson(lessonId: lessonId, studentId: studentId);

      if (success) return null;

      return ref.read(controller).error?.toString();
    },
  );
}
