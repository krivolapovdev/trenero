import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/retry_view.dart';
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

final List<StudentSummaryResponse> _dummyStudents = List.generate(
  10,
  (index) => StudentSummaryResponse(
    id: 'placeholder-$index',
    fullName: 'Student Name Placeholder',
    createdAt: DateTime.now(),
    free: false,
    statuses: const [],
  ),
);

class StudentListPage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.groups_2_outlined,
    super.selectedIcon = Icons.groups_2,
  });

  @override
  List<Widget> actions(BuildContext context) => [
    const _StudentSearchButton(),
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
      child: const _StudentListBody(),
    ),
  );
}

class _StudentSearchButton extends ConsumerWidget {
  const new();

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

class _StudentListBody extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsState = ref.watch(studentListControllerProvider);
    final filteredStudents = ref.watch(filteredStudentsProvider);

    final isLoading = studentsState.isLoading;
    final students = studentsState.value ?? const <StudentSummaryResponse>[];

    if (studentsState.hasError && students.isEmpty) {
      return _StudentListRetry(error: studentsState.error);
    }

    if (!isLoading && students.isNotEmpty && filteredStudents.isEmpty) {
      return const _StudentFilterEmpty();
    }

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

class _StudentListRetry extends ConsumerWidget {
  final Object? error;

  const new({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: '$error',
    scrollable: true,
    onRetry: () =>
        ref.read(studentListControllerProvider.notifier).getAllStudents(),
  );
}

class _StudentFilterEmpty extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) => RetryView(
    message: context.t.students.filter.empty,
    actionLabel: context.t.students.filter.reset,
    scrollable: true,
    onRetry: () => ref.read(studentFilterControllerProvider.notifier).clear(),
  );
}
