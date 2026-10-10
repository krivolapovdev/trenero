import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/features/students/repositories/student_repository.dart';
import 'package:phone/generated/models/create_student_payment_request.dart';
import 'package:phone/generated/models/create_student_request.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';

const String _studentId = 'student-1';

/// The range a single load asked the server for.
typedef _Range = ({DateTime from, DateTime to});

/// Answers the visits endpoint and remembers the ranges it was asked for.
class _FakeStudentClient implements StudentControllerClient {
  final List<_Range> visitsCalls = [];

  @override
  Future<List<VisitWithLessonResponse>> getStudentVisits({
    required String studentId,
    String? from,
    String? to,
  }) async {
    final fromDate = DateTime.parse(from!);
    final toDate = DateTime.parse(to!);

    visitsCalls.add((from: fromDate, to: toDate));

    return [_visit(fromDate), _visit(toDate)];
  }

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() =>
      throw UnimplementedError();

  @override
  Future<List<StudentResponse>> getStudents() => throw UnimplementedError();

  @override
  Future<StudentResponse> createStudent({required CreateStudentRequest body}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> getStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteStudent({required String studentId}) =>
      throw UnimplementedError();

  @override
  Future<StudentResponse> updateStudent({
    required String studentId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();

  @override
  Future<List<TransactionResponse>> getStudentPayments({
    required String studentId,
  }) => throw UnimplementedError();

  @override
  Future<TransactionResponse> createStudentPayment({
    required String studentId,
    required CreateStudentPaymentRequest body,
  }) => throw UnimplementedError();
}

VisitWithLessonResponse _visit(DateTime date) {
  final lesson = LessonResponse(
    id: 'lesson-${date.toIso8601String()}',
    date: date,
    createdAt: date,
  );

  return VisitWithLessonResponse(
    visit: VisitResponse(
      id: 'visit-${lesson.id}',
      status: VisitStatus.present,
      type: VisitType.regular,
      lessonId: lesson.id,
      studentId: _studentId,
      createdAt: date,
    ),
    lesson: lesson,
  );
}

ProviderContainer _container(_FakeStudentClient client) {
  final container = ProviderContainer(
    overrides: [
      studentRepositoryProvider.overrideWithValue(StudentRepository(client)),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

void main() {
  group('firstDayOfMonthBefore', () {
    test('steps whole months back, keeping the first day of the month', () {
      expect(
        StudentLessonsController.firstDayOfMonthBefore(
          DateTime(2026, 10, 24),
          2,
        ),
        DateTime(2026, 8, 1),
      );
    });

    test('steps over the year boundary', () {
      expect(
        StudentLessonsController.firstDayOfMonthBefore(
          DateTime(2026, 1, 15),
          3,
        ),
        DateTime(2025, 10, 1),
      );
    });
  });

  test('the first load reaches the last three months only', () async {
    final client = _FakeStudentClient();
    final container = _container(client);
    final now = DateTime.now();

    await container.read(studentLessonsProvider(_studentId).future);

    expect(client.visitsCalls, hasLength(1));
    expect(
      client.visitsCalls.single.from,
      DateTime(now.year, now.month - 2, 1),
    );
    expect(
      client.visitsCalls.single.to,
      DateTime(now.year, now.month, now.day),
    );
  });

  test('opening an earlier month loads the three months before it', () async {
    final client = _FakeStudentClient();
    final container = _container(client);
    final now = DateTime.now();

    final first = await container.read(
      studentLessonsProvider(_studentId).future,
    );

    await container
        .read(studentLessonsProvider(_studentId).notifier)
        .loadEarlierMonths(DateTime(now.year, now.month - 3));

    expect(client.visitsCalls, hasLength(2));

    final earlier = client.visitsCalls.last;
    expect(earlier.from, DateTime(now.year, now.month - 5, 1));
    expect(
      earlier.to,
      DateTime(now.year, now.month - 2, 1).subtract(const Duration(days: 1)),
    );

    final visits = container.read(studentLessonsProvider(_studentId)).value!;
    expect(visits.length, greaterThan(first.length));
  });

  test('a month inside the loaded range is not loaded again', () async {
    final client = _FakeStudentClient();
    final container = _container(client);
    final now = DateTime.now();

    await container.read(studentLessonsProvider(_studentId).future);

    await container
        .read(studentLessonsProvider(_studentId).notifier)
        .loadEarlierMonths(DateTime(now.year, now.month - 1));

    expect(client.visitsCalls, hasLength(1));
  });

  test('an earlier month is fetched while the calendars shimmer', () async {
    final client = _FakeStudentClient();
    final container = _container(client);
    final now = DateTime.now();

    await container.read(studentLessonsProvider(_studentId).future);

    final loading = container
        .read(studentLessonsProvider(_studentId).notifier)
        .loadEarlierMonths(DateTime(now.year, now.month - 3));

    expect(
      container.read(studentLessonsLoadingEarlierProvider(_studentId)),
      isTrue,
    );
    // The lessons that were already stored stay, so the calendar keeps its
    // blocks under the shimmer.
    expect(container.read(studentLessonsProvider(_studentId)).hasValue, isTrue);

    await loading;

    expect(
      container.read(studentLessonsLoadingEarlierProvider(_studentId)),
      isFalse,
    );
  });

  test(
    'a refresh drops the loaded months and opens the latest month',
    () async {
      final client = _FakeStudentClient();
      final container = _container(client);
      final now = DateTime.now();

      await container.read(studentLessonsProvider(_studentId).future);
      await container
          .read(studentLessonsProvider(_studentId).notifier)
          .loadEarlierMonths(DateTime(now.year, now.month - 3));

      container
          .read(studentLessonsMonthProvider(_studentId).notifier)
          .show(DateTime(now.year, now.month - 3));

      await container
          .read(studentLessonsProvider(_studentId).notifier)
          .refresh();

      final reload = client.visitsCalls.last;
      expect(reload.from, DateTime(now.year, now.month - 2, 1));
      expect(reload.to, DateTime(now.year, now.month, now.day));

      expect(
        container.read(studentLessonsMonthProvider(_studentId)),
        DateTime(now.year, now.month),
      );
    },
  );
}
