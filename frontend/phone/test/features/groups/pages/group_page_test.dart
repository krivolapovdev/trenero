import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/pages/group_report_page.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/lesson_controller/lesson_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/create_lesson_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/update_lesson_request.dart';
import 'package:phone/i18n/strings.g.dart';

final GroupSummaryResponse _group = GroupSummaryResponse(
  id: 'group-1',
  name: 'Group A',
  createdAt: DateTime(2026, 1, 15),
);

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day.$month.${date.year}';
}

/// Minimal answers for the group page itself plus the report it can open.
class _FakeGroupClient implements GroupControllerClient {
  final List<LessonResponse> lessons;

  new({this.lessons = const []});

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() async => [_group];

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) async => GroupReportResponse(
    groupId: groupId,
    groupName: _group.name,
    year: year,
    month: month,
    dayCount: DateTime(year, month + 1, 0).day,
    lessonDays: const [1, 2],
    students: const [
      GroupReportStudentResponse(
        studentId: 'student-1',
        fullName: 'Anna Smirnova',
        paid: true,
        presentDays: [1],
        presentCount: 1,
        lessonCount: 2,
      ),
    ],
    totalPresent: 1,
    totalLessons: 2,
  );

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) async => const [];

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) async => lessons;

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
}

class _FakeLanguageNotifier extends LanguageNotifier {
  @override
  Future<AppLocale> build() async => AppLocale.en;
}

/// Records the lessons created from the page.
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
  Future<List<LessonResponse>> getLessons() => throw UnimplementedError();

  @override
  Future<LessonResponse> getLesson({required String lessonId}) =>
      throw UnimplementedError();

  @override
  Future<LessonDetailsResponse> getLessonDetails({
    required String lessonId,
  }) async => LessonDetailsResponse(
    id: lessonId,
    date: DateTime(2026, 10, 8),
    createdAt: DateTime(2026, 10, 8),
    groupId: 'group-1',
    studentVisits: const [],
  );

  @override
  Future<LessonResponse> updateLesson({
    required String lessonId,
    required UpdateLessonRequest body,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteLesson({required String lessonId}) =>
      throw UnimplementedError();
}

Widget _wrap(_FakeGroupClient client) => ProviderScope(
  overrides: [
    groupServiceProvider.overrideWithValue(client),
    lessonServiceProvider.overrideWithValue(_FakeLessonClient()),
    languageProvider.overrideWith(_FakeLanguageNotifier.new),
  ],
  child: TranslationProvider(
    child: MaterialApp(home: GroupPage(group: _group)),
  ),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the app bar menu opens the report page', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupReportPage), findsOneWidget);
    expect(find.text('Anna Smirnova'), findsOneWidget);
  });

  testWidgets('the floating button opens the report page', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    // The actions are hidden until the radial button is expanded.
    await tester.tap(find.byType(AnimatedIcon));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.print));
    await tester.pumpAndSettle();

    expect(find.byType(GroupReportPage), findsOneWidget);
    expect(find.text('Anna Smirnova'), findsOneWidget);
  });

  testWidgets('the app bar menu opens the add lesson page', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.lessons.title));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
  });

  testWidgets('the floating button opens the add lesson page', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AnimatedIcon));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_month));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
  });

  testWidgets(
    'tapping a day without a lesson opens the create page right away',
    (tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(_wrap(_FakeGroupClient()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();

      // An empty day creates a lesson straight away, no day sheet in between.
      expect(find.byType(GroupDayLessonsBottomSheet), findsNothing);
      expect(find.byType(LessonPage), findsOneWidget);
      expect(find.text(t.lessons.groupLesson), findsOneWidget);
      expect(find.text(_formatDate(today)), findsOneWidget);
    },
  );

  testWidgets('tapping a day with a lesson opens the stored lesson', (
    tester,
  ) async {
    final today = DateTime.now();

    await tester.pumpWidget(
      _wrap(
        _FakeGroupClient(
          lessons: [
            LessonResponse(
              id: 'lesson-1',
              date: today,
              createdAt: today,
              groupId: _group.id,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('${today.day}'));
    await tester.pumpAndSettle();

    // The day sheet lists the stored lesson of the day.
    await tester.tap(find.text('${t.lessons.groupLesson} 1'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(find.text(t.lessons.groupLesson), findsOneWidget);
    expect(find.text(_formatDate(today)), findsOneWidget);
  });
}
