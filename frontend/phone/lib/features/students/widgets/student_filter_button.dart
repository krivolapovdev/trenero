import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/widgets/student_filter_bottom_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

/// Opens the student filter sheet and marks itself with the amount of
/// selected filters, so it can be reused by the list page and by search.
class StudentFilterButton extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCount = ref.watch(studentFilterControllerProvider).activeCount;

    return IconButton(
      tooltip: context.t.students.filter.title,
      icon: Badge(
        isLabelVisible: activeCount > 0,
        label: Text('$activeCount'),
        child: const Icon(FluentIcons.filter_28_regular),
      ),
      onPressed: () => AppBottomSheet.show(
        context: context,
        child: const StudentFilterBottomSheet(),
      ),
    );
  }
}
