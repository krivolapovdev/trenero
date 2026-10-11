import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/widgets/student_card.dart';
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

        return _GroupStudentsCard(
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
          child: _GroupStudentsCard(
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

class _GroupStudentsCard extends StatelessWidget {
  final List<GroupStudentSummaryResponse> students;
  final List<StudentSummaryResponse> listedStudents;
  final VoidCallback? onEdit;
  final bool isLoading;

  const new({
    required this.students,
    required this.listedStudents,
    this.onEdit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.t.students.title,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            if (onEdit != null)
              TextButton(
                onPressed: onEdit,
                child: Text(
                  context.t.edit,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: students.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 16, thickness: 1),
          itemBuilder: (context, index) {
            final student = students[index];
            final listedStudent = listedStudents
                .where((candidate) => candidate.id == student.id)
                .firstOrNull;

            return StudentCard(
              key: ValueKey(student.id),
              student: StudentSummaryResponse(
                id: student.id,
                fullName: '${index + 1}. ${student.fullName}',
                createdAt: student.createdAt,
                free: student.free,
                statuses: student.statuses,
              ),
              overrideInitials: student.fullName.initials,
              onTap: isLoading
                  ? () {}
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StudentPage(
                            student: listedStudent ?? _summaryOf(student),
                          ),
                        ),
                      );
                    },
            );
          },
        ),
      ],
    ),
  );

  static StudentSummaryResponse _summaryOf(
    GroupStudentSummaryResponse student,
  ) => StudentSummaryResponse(
    id: student.id,
    fullName: student.fullName,
    createdAt: student.createdAt,
    free: student.free,
    statuses: student.statuses,
    birthdate: student.birthdate,
    phone: student.phone,
    note: student.note,
  );
}
