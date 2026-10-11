import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';

class StudentListRetry extends ConsumerWidget {
  final Object? error;

  const new({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: '$error',
    scrollable: true,
    onRetry: () =>
        ref.read(studentListControllerProvider.notifier).getAllStudents(),
  );
}
