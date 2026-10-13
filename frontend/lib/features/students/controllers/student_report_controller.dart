import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/models/student_report.dart';
import 'package:phone/features/students/models/student_report_period.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';

final studentReportProvider =
    AsyncNotifierProvider.family<
      StudentReportController,
      StudentReport,
      StudentReportPeriod
    >(StudentReportController.new);

/// Composes the report of a single student out of the group reports of the
/// groups the student belongs to and the visits of the reported month.
class StudentReportController extends AsyncNotifier<StudentReport> {
  new(this.period);

  final StudentReportPeriod period;

  @override
  Future<StudentReport> build() async {
    final students = await ref.watch(studentListControllerProvider.future);
    final student = students
        .where((candidate) => candidate.id == period.studentId)
        .firstOrNull;

    if (student == null) {
      throw const NotFoundException();
    }

    final groupRepository = ref.watch(groupRepositoryProvider);
    final visits = await ref
        .watch(studentRepositoryProvider)
        .getStudentVisits(
          studentId: period.studentId,
          from: DateTime(period.year, period.month),
          to: DateTime(period.year, period.month + 1, 0),
        );

    return StudentReport(
      studentId: student.id,
      fullName: student.fullName,
      year: period.year,
      month: period.month,
      groups: await Future.wait(
        (student.studentGroups ?? const []).map(
          (group) =>
              _studentReportOf(groupRepository, group.id, student.fullName),
        ),
      ),
      individualLessons: _individualLessons(visits),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  /// Narrows the report of a group down to the reported student, so that the
  /// table of the report shows nobody else. A student that is no longer listed
  /// by the group keeps an empty row with the lessons of the group.
  Future<GroupReportResponse> _studentReportOf(
    GroupRepository repository,
    String groupId,
    String studentName,
  ) async {
    final report = await repository.getGroupReport(
      groupId: groupId,
      year: period.year,
      month: period.month,
    );

    final row = report.students
        .where((candidate) => candidate.studentId == period.studentId)
        .firstOrNull;

    return GroupReportResponse(
      groupId: report.groupId,
      groupName: report.groupName,
      year: report.year,
      month: report.month,
      dayCount: report.dayCount,
      lessonDays: report.lessonDays,
      students: [
        row ??
            GroupReportStudentResponse(
              studentId: period.studentId,
              fullName: studentName,
              paid: false,
              presentDays: const [],
              presentCount: 0,
              lessonCount: report.lessonDays.length,
            ),
      ],
      totalPresent: row?.presentCount ?? 0,
      totalLessons: row?.lessonCount ?? report.lessonDays.length,
    );
  }

  List<StudentReportLesson> _individualLessons(
    List<VisitWithLessonResponse> visits,
  ) {
    final lessons = StudentLessonsSection.individualVisits(visits)
        .map(
          (visit) => StudentReportLesson(
            date: visit.lesson.date,
            present: visit.visit.status == VisitStatus.present,
          ),
        )
        .toList();

    lessons.sort((first, second) => first.date.compareTo(second.date));

    return lessons;
  }
}
