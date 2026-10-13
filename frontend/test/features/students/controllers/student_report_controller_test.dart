import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/errors/app_exception.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/features/students/controllers/student_report_controller.dart';
import 'package:phone/features/students/models/student_report_period.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';

const _studentId = 'student-1';

const _period = StudentReportPeriod(
  studentId: _studentId,
  year: 2026,
  month: 2,
);

StudentSummaryResponse _student() => StudentSummaryResponse(
  id: _studentId,
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
  studentGroups: [
    GroupResponse(id: 'group-a', name: 'Group A', createdAt: DateTime(2025, 8)),
    GroupResponse(id: 'group-b', name: 'Group B', createdAt: DateTime(2025, 8)),
  ],
);

GroupReportStudentResponse _classmate() => const GroupReportStudentResponse(
  studentId: 'student-2',
  fullName: 'Ivan Petrov',
  paid: false,
  presentDays: [2],
  presentCount: 1,
  lessonCount: 2,
);

GroupReportStudentResponse _studentRow() => const GroupReportStudentResponse(
  studentId: _studentId,
  fullName: 'Anna Smirnova',
  paid: true,
  presentDays: [1],
  presentCount: 1,
  lessonCount: 2,
);

GroupReportResponse _groupReport({
  required String groupId,
  required String groupName,
  required List<GroupReportStudentResponse> students,
  List<int> lessonDays = const [1, 2],
}) => GroupReportResponse(
  groupId: groupId,
  groupName: groupName,
  year: _period.year,
  month: _period.month,
  dayCount: 28,
  lessonDays: lessonDays,
  students: students,
  totalPresent: students.fold(0, (sum, student) => sum + student.presentCount),
  totalLessons: students.fold(0, (sum, student) => sum + student.lessonCount),
);

Map<String, GroupReportResponse> _reportsOf(
  List<GroupReportStudentResponse> groupAStudents,
  List<GroupReportStudentResponse> groupBStudents, {
  List<int> groupALessonDays = const [1, 2],
}) => {
  'group-a': _groupReport(
    groupId: 'group-a',
    groupName: 'Group A',
    students: groupAStudents,
    lessonDays: groupALessonDays,
  ),
  'group-b': _groupReport(
    groupId: 'group-b',
    groupName: 'Group B',
    students: groupBStudents,
  ),
};

VisitWithLessonResponse _visit({
  required DateTime date,
  required VisitStatus status,
  String? groupId,
}) => VisitWithLessonResponse(
  visit: VisitResponse(
    id: 'visit-${date.day}',
    status: status,
    type: VisitType.regular,
    lessonId: 'lesson-${date.day}',
    studentId: _studentId,
    createdAt: date,
  ),
  lesson: LessonResponse(
    id: 'lesson-${date.day}',
    date: date,
    createdAt: date,
    groupId: groupId,
  ),
);

class _FakeGroupClient implements GroupControllerClient {
  new(this.reports);

  final Map<String, GroupReportResponse> reports;

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) async => reports[groupId]!;

  @override
  Future<GroupResponse> createGroup({required CreateGroupRequest body}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteGroup({required String groupId}) =>
      throw UnimplementedError();

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() =>
      throw UnimplementedError();

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError();

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) => throw UnimplementedError();

  @override
  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

class _FakeStudentClient implements StudentControllerClient {
  new(this.visits);

  final List<VisitWithLessonResponse> visits;

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    DateTime? from,
    DateTime? to,
  }) async => visits;

  @override
  Future<StudentResponse> createStudent({required CreateStudentRequest body}) =>
      throw UnimplementedError();

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
}

class _FakeStudentListController extends StudentListController {
  new(this.students);

  final List<StudentSummaryResponse> students;

  @override
  Future<List<StudentSummaryResponse>> build() async => students;
}

ProviderContainer _container({
  required Map<String, GroupReportResponse> reports,
  List<VisitWithLessonResponse> visits = const [],
  List<StudentSummaryResponse>? students,
}) {
  final container = ProviderContainer(
    overrides: [
      groupServiceProvider.overrideWithValue(_FakeGroupClient(reports)),
      studentServiceProvider.overrideWithValue(_FakeStudentClient(visits)),
      studentListControllerProvider.overrideWith(
        () => _FakeStudentListController(students ?? [_student()]),
      ),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

void main() {
  test('asks for the report of every group of the student', () async {
    final container = _container(
      reports: _reportsOf(
        [_studentRow(), _classmate()],
        [_classmate(), _studentRow()],
      ),
    );

    final report = await container.read(studentReportProvider(_period).future);

    expect(report.studentId, _studentId);
    expect(report.fullName, 'Anna Smirnova');
    expect(report.year, 2026);
    expect(report.month, 2);
    expect(report.groups.map((group) => group.groupName), [
      'Group A',
      'Group B',
    ]);
  });

  test('keeps every table to the reported student alone', () async {
    final container = _container(
      reports: _reportsOf(
        [_studentRow(), _classmate()],
        [_classmate(), _studentRow()],
      ),
    );

    final report = await container.read(studentReportProvider(_period).future);

    for (final group in report.groups) {
      expect(group.students.map((row) => row.studentId), [_studentId]);

      expect(
        group.students.single.fullName,
        'Anna Smirnova',
        reason: 'no other student may show up in the table of a group',
      );
      expect(group.totalPresent, 1);
      expect(group.totalLessons, 2);
    }
  });

  test(
    'keeps a group that does not list the student with an empty row',
    () async {
      final container = _container(
        reports: _reportsOf(
          [_classmate()],
          [_studentRow()],
          groupALessonDays: const [1, 2, 3],
        ),
      );

      final report = await container.read(
        studentReportProvider(_period).future,
      );

      final row = report.groups.first.students.single;

      expect(row.studentId, _studentId);
      expect(row.fullName, 'Anna Smirnova');
      expect(row.presentDays, isEmpty);
      expect(row.presentCount, 0);
      expect(row.lessonCount, 3);
    },
  );

  test(
    'collects the individual lessons of the month, ordered by date',
    () async {
      final container = _container(
        reports: _reportsOf(
          [_studentRow(), _classmate()],
          [_classmate(), _studentRow()],
        ),
        visits: [
          _visit(date: DateTime(2026, 2, 10), status: VisitStatus.present),
          _visit(date: DateTime(2026, 2, 3), status: VisitStatus.absent),
          _visit(
            date: DateTime(2026, 2, 5),
            status: VisitStatus.present,
            groupId: 'group-a',
          ),
        ],
      );

      final report = await container.read(
        studentReportProvider(_period).future,
      );

      expect(report.individualLessons.map((lesson) => lesson.date), [
        DateTime(2026, 2, 3),
        DateTime(2026, 2, 10),
      ]);
      expect(report.individualLessons.map((lesson) => lesson.present), [
        false,
        true,
      ]);
      expect(report.individualPresentCount, 1);
      expect(report.individualLessonCount, 2);
    },
  );

  test('leaves the individual lessons empty when the month has none', () async {
    final container = _container(
      reports: _reportsOf(
        [_studentRow(), _classmate()],
        [_classmate(), _studentRow()],
      ),
      visits: [
        _visit(
          date: DateTime(2026, 2, 5),
          status: VisitStatus.present,
          groupId: 'group-a',
        ),
      ],
    );

    final report = await container.read(studentReportProvider(_period).future);

    expect(report.individualLessons, isEmpty);
    expect(report.individualPresentCount, 0);
    expect(report.individualLessonCount, 0);
  });

  test('fails when the student is no longer in the list', () async {
    final container = _container(
      reports: _reportsOf([_classmate()], [_classmate()]),
      students: const [],
    );

    final subscription = container.listen(
      studentReportProvider(_period),
      (previous, next) {},
    );
    addTearDown(subscription.close);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(
      container.read(studentReportProvider(_period)).error,
      isA<NotFoundException>(),
      reason: 'the report has nothing to head itself with',
    );
  });
}
