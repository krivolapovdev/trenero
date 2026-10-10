import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/controllers/lesson_mutation_controller.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/students/controllers/student_list_controller.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/lesson_controller/lesson_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';

const String _groupId = 'group-1';

final GroupStudentSummaryResponse _student = GroupStudentSummaryResponse(
  id: 'student-1',
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2026, 1, 15),
  free: false,
  statuses: const [],
);

/// Serves the lessons and the students of the group and remembers how often
/// each of them was read.
class _FakeGroupClient implements GroupControllerClient {
  int lessonCalls = 0;
  int studentCalls = 0;

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) async {
    lessonCalls++;

    return const [];
  }

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) async {
    studentCalls++;

    return [_student];
  }

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() =>
      throw UnimplementedError();

  @override
  Future<GroupResponse> createGroup({required CreateGroupRequest body}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteGroup({required String groupId}) =>
      throw UnimplementedError();

  @override
  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) => throw UnimplementedError();
}

/// Accepts the lessons the controller writes.
class _FakeLessonClient implements LessonControllerClient {
  final List<CreateLessonRequest> createBodies = [];

  @override
  Future<LessonResponse> createLesson({
    required CreateLessonRequest body,
  }) async {
    createBodies.add(body);

    return LessonResponse(
      id: 'lesson-1',
      date: body.date,
      createdAt: DateTime(2026, 10, 8),
      groupId: body.groupId,
    );
  }

  @override
  Future<LessonResponse> updateLesson({
    required String lessonId,
    required UpdateLessonRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteLesson({required String lessonId}) =>
      throw UnimplementedError();

  @override
  Future<LessonDetailsResponse> getLessonDetails({required String lessonId}) =>
      throw UnimplementedError();
}

/// Keeps the student list the mutation reloads out of the network.
class _FakeStudentListController extends StudentListController {
  @override
  Future<List<StudentSummaryResponse>> build() async => const [];

  @override
  Future<void> getAllStudents({bool forceRefresh = false}) async {}
}

ProviderContainer _container(
  _FakeGroupClient groupClient,
  _FakeLessonClient lessonClient,
) {
  final container = ProviderContainer(
    overrides: [
      groupRepositoryProvider.overrideWithValue(GroupRepository(groupClient)),
      lessonServiceProvider.overrideWithValue(lessonClient),
      studentListControllerProvider.overrideWith(
        _FakeStudentListController.new,
      ),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

void main() {
  test('creating a lesson reloads the lessons and the students of the group', () async {
    final groupClient = _FakeGroupClient();
    final lessonClient = _FakeLessonClient();
    final container = _container(groupClient, lessonClient);

    // The group page keeps the students of its group alive; the mutation has to
    // reload them so their badges match the lesson that was just recorded.
    container.listen(groupStudentsProvider(_groupId), (_, _) {});
    await container.read(groupStudentsProvider(_groupId).future);
    expect(groupClient.studentCalls, 1);

    final created = await container
        .read(lessonMutationControllerProvider.notifier)
        .createLesson(
          groupId: _groupId,
          date: DateTime(2026, 10, 8),
          students: [_student],
          attendance: {
            _student.id: const LessonAttendance(
              status: VisitStatus.present,
              type: VisitType.regular,
            ),
          },
        );

    expect(created, isTrue);
    expect(lessonClient.createBodies, hasLength(1));

    // The lessons of the group are reloaded...
    expect(groupClient.lessonCalls, greaterThan(0));

    // ...and the students of the group are read again, so the group page shows
    // the badges the new lesson changes.
    await container.read(groupStudentsProvider(_groupId).future);
    expect(groupClient.studentCalls, 2);
  });
}
