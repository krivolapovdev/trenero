import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/services/lesson_service.dart';
import 'package:phone/features/groups/widgets/delete_group_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/group_header.dart';
import 'package:phone/features/groups/widgets/group_report_bottom_sheet.dart';
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

class _FakeGroupClient implements GroupControllerClient {
  final List<LessonResponse> lessons;
  final List<GroupSummaryResponse> groups;

  final List<String> deletedGroupIds = [];

  new({this.lessons = const [], this.groups = const []});

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() async =>
      groups.isEmpty ? [_group] : groups;

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
  Future<void> deleteGroup({required String groupId}) async {
    deletedGroupIds.add(groupId);
  }

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
  Future<LessonDetailsResponse> getLessonDetails({
    required String lessonId,
  }) async => LessonDetailsResponse(
    id: lessonId,
    date: DateTime(2026, 10, 8),
    createdAt: DateTime(2026, 10, 8),
    groupId: 'group-1',
    studentVisits: const [],
    students: const [],
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

  testWidgets('the app bar menu opens the report sheet', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.groups.report));
    await tester.pumpAndSettle();

    expect(find.byType(GroupReportBottomSheet), findsOneWidget);
    expect(find.text(t.print), findsOneWidget);
  });

  testWidgets('the app bar menu opens the add lesson page', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.lessons.title));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(
      find.text(t.lessons.groupLessonTitle(name: _group.name)),
      findsOneWidget,
    );
  });

  testWidgets('the create button of the calendar opens the add lesson page', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.create));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(
      find.text(t.lessons.groupLessonTitle(name: _group.name)),
      findsOneWidget,
    );
  });

  testWidgets(
    'tapping a day without a lesson opens the create page right away',
    (tester) async {
      final today = DateTime.now();

      await tester.pumpWidget(_wrap(_FakeGroupClient()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();

      expect(find.byType(GroupDayLessonsBottomSheet), findsNothing);
      expect(find.byType(LessonPage), findsOneWidget);
      expect(
        find.text(t.lessons.groupLessonTitle(name: _group.name)),
        findsOneWidget,
      );
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

    expect(find.byType(GroupDayLessonsBottomSheet), findsNothing);
    expect(find.byType(LessonPage), findsOneWidget);
    expect(
      find.text(t.lessons.groupLessonTitle(name: _group.name)),
      findsOneWidget,
    );
    expect(find.text(_formatDate(today)), findsOneWidget);
  });

  testWidgets('tapping a day with multiple lessons opens the bottom sheet', (
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
            LessonResponse(
              id: 'lesson-2',
              date: today,
              createdAt: today.add(const Duration(hours: 1)),
              groupId: _group.id,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('${today.day}'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupDayLessonsBottomSheet), findsOneWidget);

    await tester.tap(find.text('${t.lessons.groupLesson} 1'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonPage), findsOneWidget);
    expect(
      find.text(t.lessons.groupLessonTitle(name: _group.name)),
      findsOneWidget,
    );
    expect(find.text(_formatDate(today)), findsOneWidget);
  });

  testWidgets('the menu deletes the group after a confirmation', (
    tester,
  ) async {
    final client = _FakeGroupClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupServiceProvider.overrideWithValue(client),
          lessonServiceProvider.overrideWithValue(_FakeLessonClient()),
          languageProvider.overrideWith(_FakeLanguageNotifier.new),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GroupPage(group: _group)),
                ),
                child: const Text('open the group'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open the group'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.delete));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteGroupBottomSheet), findsOneWidget);
    expect(find.text(t.groups.deleteGroup), findsOneWidget);
    expect(find.text(t.groups.deleteGroupMessage), findsOneWidget);
    expect(client.deletedGroupIds, isEmpty);

    await tester.tap(find.text(t.delete));
    await tester.pumpAndSettle();

    expect(client.deletedGroupIds, ['group-1']);

    expect(find.byType(GroupPage), findsNothing);
  });

  testWidgets(
    'merged header displays large title and badges when unscrolled, and collapses when scrolled',
    (tester) async {
      final groupWithPrice = GroupSummaryResponse(
        id: 'group-1',
        name: 'Group A',
        countOfStudents: 5,
        defaultPrice: 3500,
        createdAt: DateTime(2026, 1, 15),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupServiceProvider.overrideWithValue(
              _FakeGroupClient(groups: [groupWithPrice]),
            ),
            lessonServiceProvider.overrideWithValue(_FakeLessonClient()),
            languageProvider.overrideWith(_FakeLanguageNotifier.new),
          ],
          child: TranslationProvider(
            child: MaterialApp(home: GroupPage(group: groupWithPrice)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Unscrolled:
      // Large title is visible
      expect(find.text('Group A'), findsOneWidget);
      // Student count badge and price badge are visible
      expect(
        find.descendant(of: find.byType(CardBadge), matching: find.text('5')),
        findsOneWidget,
      );
      expect(
        find.text(
          groupWithPrice.defaultPrice!.toFormattedAmount(showSign: false),
        ),
        findsOneWidget,
      );
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);

      // Scroll down to collapse header
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Scrolled:
      // Pinned compact title is now visible
      expect(find.text('Group A'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);

      // Refresh indicator edgeOffset is positioned under the group header
      final indicator = tester.widget<CustomMaterialIndicator>(
        find.byType(CustomMaterialIndicator),
      );
      expect(
        indicator.edgeOffset,
        greaterThan(GroupHeaderDelegate.contentHeight),
      );
    },
  );

  testWidgets(
    'allows only two stable versions: snaps to full or short when scroll finishes',
    (tester) async {
      tester.view.physicalSize = const Size(400, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyLessons = List.generate(
        10,
        (i) => LessonResponse(
          id: 'lesson-$i',
          date: DateTime(2026, 10, i + 1),
          createdAt: DateTime(2026, 10, i + 1),
          groupId: _group.id,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupServiceProvider.overrideWithValue(
              _FakeGroupClient(lessons: dummyLessons),
            ),
            lessonServiceProvider.overrideWithValue(_FakeLessonClient()),
            languageProvider.overrideWith(_FakeLanguageNotifier.new),
          ],
          child: TranslationProvider(
            child: MaterialApp(home: GroupPage(group: _group)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );

      // Drag slightly (30px) and release -> should snap back to 0 (Full)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -30));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, equals(0.0));

      // Drag past midpoint (90px) and release -> should snap to short (contentHeight)
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -90));
      await tester.pumpAndSettle();
      expect(
        scrollable.position.pixels,
        equals(GroupHeaderDelegate.contentHeight),
      );
    },
  );
}
