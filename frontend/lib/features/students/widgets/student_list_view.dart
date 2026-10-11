import 'package:flutter/material.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentListView extends StatelessWidget {
  final List<StudentSummaryResponse> students;
  final bool isLoading;

  const new({super.key, required this.students, this.isLoading = false});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16.0),
    physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    separatorBuilder: (context, index) => const SizedBox(height: 12.0),
    itemCount: students.length,
    itemBuilder: (context, index) {
      final student = students[index];

      return Hero(
        tag: 'student-card-${student.id}',
        child: Material(
          type: MaterialType.transparency,
          child: StudentCard(
            student: student,
            onTap: isLoading
                ? () {}
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudentPage(student: student),
                      ),
                    );
                  },
          ),
        ),
      );
    },
  );
}
