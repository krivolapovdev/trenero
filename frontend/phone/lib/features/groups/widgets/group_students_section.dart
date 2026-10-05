import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/export.dart';

class GroupStudentsSection extends ConsumerWidget {
  final String groupId;

  const new({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(groupStudentsProvider(groupId));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
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
                onTap: () {
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading students: $error')),
    );
  }
}
