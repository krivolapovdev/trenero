import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/widgets/student_filter_empty.dart';
import 'package:phone/features/students/widgets/student_list_dummy_students.dart';
import 'package:phone/features/students/widgets/student_list_empty.dart';
import 'package:phone/features/students/widgets/student_list_retry.dart';
import 'package:phone/features/students/widgets/student_list_view.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentListBody extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsState = ref.watch(studentListControllerProvider);
    final filteredStudents = ref.watch(filteredStudentsProvider);

    final isLoading = studentsState.isLoading;
    final students = studentsState.value ?? const <StudentSummaryResponse>[];

    if (studentsState.hasError && students.isEmpty) {
      return StudentListRetry(error: studentsState.error);
    }

    if (!isLoading && students.isEmpty) {
      return const StudentListEmpty();
    }

    if (!isLoading && filteredStudents.isEmpty) {
      return const StudentFilterEmpty();
    }

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: StudentListView(
        students: isLoading && students.isEmpty
            ? studentListDummyStudents
            : filteredStudents,
        isLoading: isLoading,
      ),
    );
  }
}
