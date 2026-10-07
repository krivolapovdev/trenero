import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/export.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupStudentsSection extends ConsumerWidget {
  final String groupId;
  final int? studentCount;

  const new({super.key, required this.groupId, this.studentCount});

  static List<GroupStudentSummaryResponse> _dummyStudents(int count) =>
      List.generate(
        count,
        (index) => GroupStudentSummaryResponse(
          id: 'placeholder-$index',
          fullName: 'Student Name Placeholder',
          createdAt: DateTime.now(),
          statuses: const [],
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(groupStudentsProvider(groupId));

    return studentsAsync.when(
      skipLoadingOnRefresh: false,

      data: (students) {
        if (students.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildSection(context, students);
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
          child: _buildSection(context, displayStudents, isLoading: true),
        );
      },
      error: (error, stack) =>
          Center(child: Text('Error loading students: $error')),
    );
  }

  Widget _buildSection(
    BuildContext context,
    List<GroupStudentSummaryResponse> students, {
    bool isLoading = false,
  }) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: students.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 16, thickness: 1),
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentCard(
          student: StudentSummaryResponse(
            id: student.id,
            fullName: '${index + 1}. ${student.fullName}',
            createdAt: student.createdAt,
            statuses: student.statuses,
          ),
          onTap: isLoading
              ? () {}
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StudentPage(
                        student: StudentSummaryResponse(
                          id: student.id,
                          fullName: student.fullName,
                          createdAt: student.createdAt,
                          statuses: student.statuses,
                        ),
                      ),
                    ),
                  );
                },
        );
      },
    ),
  );
}
