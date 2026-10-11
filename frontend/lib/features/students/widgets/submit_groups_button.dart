import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/assign_student_group_controller.dart';
import 'package:phone/i18n/strings.g.dart';

class SubmitGroupsButton extends ConsumerWidget {
  final bool hasChanges;
  final VoidCallback onSubmit;

  const new({super.key, required this.hasChanges, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(
      assignStudentGroupControllerProvider.select((state) => state.isLoading),
    );

    return TextButton.icon(
      onPressed: (!hasChanges || isSubmitting) ? null : onSubmit,
      icon: isSubmitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      label: Text(context.t.edit, style: const TextStyle(fontSize: 18)),
    );
  }
}
