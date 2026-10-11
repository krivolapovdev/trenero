import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/delete_confirmation_sheet.dart';
import 'package:phone/features/groups/controllers/lesson_mutation_controller.dart';
import 'package:phone/i18n/strings.g.dart';

class DeleteLessonBottomSheet extends ConsumerWidget {
  final String lessonId;
  final String groupId;

  const new({super.key, required this.lessonId, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DeleteConfirmationSheet(
    title: context.t.lessons.deleteLesson,
    message: context.t.lessons.deleteLessonMessage,
    delete: () async {
      final controller = lessonMutationControllerProvider;

      final success = await ref
          .read(controller.notifier)
          .deleteLesson(lessonId: lessonId, groupId: groupId);

      if (success) return null;

      return ref.read(controller).error?.toString();
    },
  );
}
