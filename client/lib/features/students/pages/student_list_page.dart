import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/widgets/create_student_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_filter_button.dart';
import 'package:phone/features/students/widgets/student_list_body.dart';
import 'package:phone/features/students/widgets/student_search_button.dart';

class StudentListPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.groups_2_outlined,
    super.selectedIcon = Icons.groups_2,
  });

  @override
  Widget titleView(BuildContext context) => Consumer(
    builder: (context, ref, child) =>
        titleWithCount(context, ref.watch(filteredStudentsProvider).length),
  );

  @override
  List<Widget> actions(BuildContext context) => [
    const StudentSearchButton(),
    const StudentFilterButton(),
    IconButton(
      icon: const Icon(FluentIcons.person_add_24_regular),
      onPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateStudentBottomSheet(),
      ),
    ),
    const SizedBox(width: 8),
  ];

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, child) => CustomMaterialIndicator(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      onRefresh: () async {
        await ref
            .read(studentListControllerProvider.notifier)
            .getAllStudents(forceRefresh: true);

        ref
          ..invalidate(studentLessonsProvider)
          ..invalidate(studentPaymentsControllerProvider);
      },
      child: const StudentListBody(),
    ),
  );
}
