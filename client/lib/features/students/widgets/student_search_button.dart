import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/widgets/student_search_delegate.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentSearchButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStudents = ref.watch(
      studentListControllerProvider.select(
        (state) => state.value ?? const <StudentSummaryResponse>[],
      ),
    );

    return IconButton(
      icon: const Icon(FluentIcons.search_24_regular),
      onPressed: () {
        showSearch(
          context: context,
          delegate: StudentSearchDelegate(
            currentStudents,
            '${MaterialLocalizations.of(context).searchFieldLabel}...',
          ),
        );
      },
    );
  }
}
