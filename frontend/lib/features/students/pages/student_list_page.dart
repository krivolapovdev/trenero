import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_payment_list_controller.dart';
import 'package:phone/features/students/widgets/create_student_bottom_sheet.dart';
import 'package:phone/features/students/widgets/student_filter_button.dart';
import 'package:phone/features/students/widgets/student_list_view.dart';
import 'package:phone/features/students/widgets/student_search_delegate.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentListPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.groups_2_outlined,
    super.selectedIcon = Icons.groups_2,
  });

  static final List<StudentSummaryResponse> _dummyStudents = List.generate(
    10,
    (index) => StudentSummaryResponse(
      id: 'placeholder-$index',
      fullName: 'Student Name Placeholder',
      createdAt: DateTime.now(),
      free: false,
      statuses: [],
    ),
  );

  @override
  List<Widget> actions(BuildContext context) => [
    Consumer(
      builder: (context, ref, child) {
        final studentsState = ref.watch(studentListControllerProvider);

        return IconButton(
          icon: const Icon(FluentIcons.search_24_regular),
          onPressed: () {
            final currentStudents = studentsState.value ?? [];

            showSearch(
              context: context,
              delegate: StudentSearchDelegate(
                currentStudents,
                '${MaterialLocalizations.of(context).searchFieldLabel}...',
              ),
            );
          },
        );
      },
    ),
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
    builder: (context, ref, child) {
      final studentsState = ref.watch(studentListControllerProvider);
      final filter = ref.watch(studentFilterControllerProvider);
      final isLoading = studentsState.isLoading;
      final hasError = studentsState.hasError;
      final students = studentsState.value ?? [];
      final filteredStudents = students.where(filter.matches).toList();

      return CustomMaterialIndicator(
        color: Colors.black,
        clipBehavior: Clip.antiAlias,
        onRefresh: () async {
          await ref
              .read(studentListControllerProvider.notifier)
              .getAllStudents(forceRefresh: true);

          ref.invalidate(studentLessonsProvider);
          ref.invalidate(studentPaymentsControllerProvider);
        },
        child: _buildBody(
          context,
          ref,
          studentsState,
          students,
          filteredStudents,
          isLoading,
          hasError,
        ),
      );
    },
  );

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue studentsState,
    List<StudentSummaryResponse> students,
    List<StudentSummaryResponse> filteredStudents,
    bool isLoading,
    bool hasError,
  ) {
    if (hasError && students.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${studentsState.error}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref
                        .read(studentListControllerProvider.notifier)
                        .getAllStudents(),
                    child: Text(context.t.repeat),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!isLoading && students.isNotEmpty && filteredStudents.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.t.students.filter.empty),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref
                        .read(studentFilterControllerProvider.notifier)
                        .clear(),
                    child: Text(context.t.students.filter.reset),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // if (!isLoading && students.isEmpty) {
    //   return LayoutBuilder(
    //     builder: (context, constraints) => SingleChildScrollView(
    //       physics: const AlwaysScrollableScrollPhysics(),
    //       child: ConstrainedBox(
    //         constraints: BoxConstraints(minHeight: constraints.maxHeight),
    //         child: EmptyState(
    //           buttonText: context.t.students.createFirstStudent,
    //           subtitle: context.t.students.emptySubtitle,
    //           onButtonPressed: () => AppBottomSheet.show(
    //             context: context,
    //             child: const CreateStudentBottomSheet(),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: StudentListView(
        students: isLoading && students.isEmpty
            ? _dummyStudents
            : filteredStudents,
        isLoading: isLoading,
      ),
    );
  }
}
