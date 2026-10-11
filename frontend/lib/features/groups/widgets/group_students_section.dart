import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/widgets/group_students_card.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/export.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupStudentsSection extends ConsumerWidget {
  final String groupId;
  final int? studentCount;

  final VoidCallback? onEdit;

  const new({super.key, required this.groupId, this.studentCount, this.onEdit});

  static List<GroupStudentSummaryResponse> _dummyStudents(int count) =>
      List.generate(
        count,
        (index) => GroupStudentSummaryResponse(
          id: 'placeholder-$index',
          fullName: 'Student Name Placeholder',
          createdAt: DateTime.now(),
          free: false,
          statuses: const [],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(groupStudentsProvider(groupId));

    final listedStudents =
        ref.watch(studentListControllerProvider).value ??
        const <StudentSummaryResponse>[];

    return studentsAsync.when(
      skipLoadingOnRefresh: false,

      data: (students) {
        if (students.isEmpty) {
          return const SizedBox.shrink();
        }

        return GroupStudentsCard(
          students: students,
          listedStudents: listedStudents,
          onEdit: onEdit,
        );
      },
      loading: () {
        final previousData = studentsAsync.value;
        final hasValidData = previousData != null && previousData.isNotEmpty;

        final displayStudents = hasValidData
            ? previousData
            : _dummyStudents(
                (studentCount == null || studentCount == 0) ? 1 : studentCount!,
              );

        return Skeletonizer(
          ignorePointers: false,
          child: GroupStudentsCard(
            students: displayStudents,
            listedStudents: listedStudents,
            onEdit: onEdit,
            isLoading: true,
          ),
        );
      },
      error: (error, stack) =>
          Center(child: Text(context.t.students.errorLoading(error: error))),
    );
  }
}

