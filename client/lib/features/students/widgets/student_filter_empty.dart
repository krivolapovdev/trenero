import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentFilterEmpty extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: context.t.students.filter.empty,
    actionLabel: context.t.reset,
    scrollable: true,
    onRetry: () => ref.read(studentFilterControllerProvider.notifier).clear(),
  );
}
