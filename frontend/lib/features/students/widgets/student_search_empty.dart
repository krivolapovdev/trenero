import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentSearchEmpty extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.t.students.filter.empty),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () =>
              ref.read(studentFilterControllerProvider.notifier).clear(),
          child: Text(context.t.students.filter.reset),
        ),
      ],
    ),
  );
}
