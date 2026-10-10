import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/features/students/controllers/create_student_controller.dart';
import 'package:phone/features/students/widgets/student_form_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

class CreateStudentBottomSheet extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CreateStudentBottomSheet> createState() =>
      _CreateStudentBottomSheetState();
}

class _CreateStudentBottomSheetState
    extends ConsumerState<CreateStudentBottomSheet> {
  Future<void> _onSave({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
  }) async {
    final success = await ref
        .read(createStudentControllerProvider.notifier)
        .saveStudent(
          fullName: fullName,
          birthdate: birthdate,
          phone: phone,
          note: note,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      final state = ref.read(createStudentControllerProvider);
      final error = state.error;
      if (error != null) {
        AppSnackBar.show(context, 'Error: $error', SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createStudentControllerProvider).isLoading;

    return StudentFormSheet(
      title: context.t.students.createStudent,
      submitLabel: context.t.create,
      submitIcon: Icons.add,
      isLoading: isLoading,
      onSubmit: _onSave,
    );
  }
}
