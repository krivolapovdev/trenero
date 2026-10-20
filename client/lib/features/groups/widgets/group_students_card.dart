import 'package:flutter/material.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/export.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupStudentsCard extends StatelessWidget {
  final List<GroupStudentSummaryResponse> students;
  final List<StudentSummaryResponse> listedStudents;
  final VoidCallback? onEdit;
  final bool isLoading;

  const new({
    super.key,
    required this.students,
    required this.listedStudents,
    this.onEdit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    padding: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
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
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: students.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final student = students[index];
            final listedStudent = listedStudents
                .where((candidate) => candidate.id == student.id)
                .firstOrNull;

            return StudentCard(
              key: ValueKey(student.id),
              student: StudentSummaryResponse(
                id: student.id,
                fullName: student.fullName,
                createdAt: student.createdAt,
                free: student.free,
                statuses: student.statuses,
              ),
              borderRadius: BorderRadius.zero,
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
