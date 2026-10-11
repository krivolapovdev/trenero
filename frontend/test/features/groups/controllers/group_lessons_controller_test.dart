import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/repositories/group_repository.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';

const String _groupId = 'group-1';

/// The range a single load asked the server for.
typedef _Range = ({DateTime from, DateTime to});

/// Answers the lessons endpoint and remembers the ranges it was asked for.
class _FakeGroupClient implements GroupControllerClient {
  final List<_Range> lessonCalls = [];

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) async {
    lessonCalls.add((from: from, to: to));

    return [_lesson(from), _lesson(to)];
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
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) => throw UnimplementedError();

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) => throw UnimplementedError();
}

LessonResponse _lesson(DateTime date) => LessonResponse(
  id: 'lesson-${date.toIso8601String()}',
  date: date,
  createdAt: date,
);

ProviderContainer _container(_FakeGroupClient client) {
  final container = ProviderContainer(
    overrides: [
      groupRepositoryProvider.overrideWithValue(GroupRepository(client)),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

void main() {
  group('firstDayOfMonthBefore', () {
    test('steps whole months back, keeping the first day of the month', () {
      expect(
        GroupLessonsController.firstDayOfMonthBefore(DateTime(2026, 10, 24), 2),
        DateTime(2026, 8, 1),
      );
    });

    test('steps over the year boundary', () {
      expect(
        GroupLessonsController.firstDayOfMonthBefore(DateTime(2026, 1, 15), 3),
        DateTime(2025, 10, 1),
      );
    });
  });

  test('the first load reaches the last three months only', () async {
    final client = _FakeGroupClient();
    final container = _container(client);
    final now = DateTime.now();

    await container.read(groupLessonsProvider(_groupId).future);

    expect(client.lessonCalls, hasLength(1));
    expect(
      client.lessonCalls.single.from,
      DateTime(now.year, now.month - 2, 1),
    );
    expect(
      client.lessonCalls.single.to,
      DateTime(now.year, now.month, now.day),
    );
  });

  test('opening an earlier month loads the three months before it', () async {
    final client = _FakeGroupClient();
    final container = _container(client);
    final now = DateTime.now();

    final first = await container.read(groupLessonsProvider(_groupId).future);

    await container
        .read(groupLessonsProvider(_groupId).notifier)
        .loadEarlierMonths(DateTime(now.year, now.month - 3));

    expect(client.lessonCalls, hasLength(2));

    final earlier = client.lessonCalls.last;
    expect(earlier.from, DateTime(now.year, now.month - 5, 1));
    expect(
      earlier.to,
      DateTime(now.year, now.month - 2, 1).subtract(const Duration(days: 1)),
    );

    final lessons = container.read(groupLessonsProvider(_groupId)).value!;
    expect(lessons.length, greaterThan(first.length));
  });

  test('an earlier month is fetched while the calendar shimmers', () async {
    final client = _FakeGroupClient();
    final container = _container(client);
    final now = DateTime.now();

    await container.read(groupLessonsProvider(_groupId).future);

    final loading = container
        .read(groupLessonsProvider(_groupId).notifier)
        .loadEarlierMonths(DateTime(now.year, now.month - 3));

    expect(
      container.read(groupLessonsLoadingEarlierProvider(_groupId)),
      isTrue,
    );
    // The lessons that were already stored stay, so the calendar keeps its
    // blocks under the shimmer.
    expect(container.read(groupLessonsProvider(_groupId)).hasValue, isTrue);

    await loading;

    expect(
      container.read(groupLessonsLoadingEarlierProvider(_groupId)),
      isFalse,
    );
  });

  test(
    'a refresh drops the loaded months and opens the latest month',
    () async {
      final client = _FakeGroupClient();
      final container = _container(client);
      final now = DateTime.now();

      await container.read(groupLessonsProvider(_groupId).future);
      await container
          .read(groupLessonsProvider(_groupId).notifier)
          .loadEarlierMonths(DateTime(now.year, now.month - 3));

      container
          .read(groupLessonsMonthProvider(_groupId).notifier)
          .show(DateTime(now.year, now.month - 3));

      await container.read(groupLessonsProvider(_groupId).notifier).refresh();

      final reload = client.lessonCalls.last;
      expect(reload.from, DateTime(now.year, now.month - 2, 1));
      expect(reload.to, DateTime(now.year, now.month, now.day));

      expect(
        container.read(groupLessonsMonthProvider(_groupId)),
        DateTime(now.year, now.month),
      );
    },
  );

  test('a month that is asked for during a load is loaded too', () async {
    final client = _FakeGroupClient();
    final container = _container(client);
    final now = DateTime.now();

    await container.read(groupLessonsProvider(_groupId).future);

    final notifier = container.read(groupLessonsProvider(_groupId).notifier);

    // A fast run back through the months asks for several of them while the
    // first window is still on its way.
    final first = notifier.loadEarlierMonths(DateTime(now.year, now.month - 3));
    final further = notifier.loadEarlierMonths(
      DateTime(now.year, now.month - 6),
    );

    await Future.wait([first, further]);

    // The window that was already running reaches the month asked for last.
    expect(client.lessonCalls, hasLength(3));
    expect(client.lessonCalls.last.from, DateTime(now.year, now.month - 8, 1));
  });

  test('the read reaches the month the calendar shows', () async {
    final client = _FakeGroupClient();
    final container = _container(client);
    final now = DateTime.now();
    final shownMonth = DateTime(now.year, now.month - 6);

    // The calendar was left on a month that lies before the last three months,
    // the way it survives a reload of the lessons.
    container
        .read(groupLessonsMonthProvider(_groupId).notifier)
        .show(shownMonth);

    await container.read(groupLessonsProvider(_groupId).future);

    // The window reaches back to the month that is shown instead of leaving it
    // empty.
    expect(client.lessonCalls.single.from, shownMonth);
  });
}
