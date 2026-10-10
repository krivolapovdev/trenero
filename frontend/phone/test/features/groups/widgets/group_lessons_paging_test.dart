import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/widgets/group_lessons_section.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

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

    return [
      LessonResponse(
        id: 'lesson-${from.toIso8601String()}',
        date: from,
        createdAt: from,
      ),
    ];
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

class _FakeLanguageNotifier extends LanguageNotifier {
  @override
  Future<AppLocale> build() async => AppLocale.en;
}

Widget _wrap(_FakeGroupClient client) => ProviderScope(
  overrides: [
    groupServiceProvider.overrideWithValue(client),
    languageProvider.overrideWith(_FakeLanguageNotifier.new),
  ],
  child: TranslationProvider(
    child: MaterialApp(
      home: Scaffold(body: GroupLessonsSection(groupId: 'group-1')),
    ),
  ),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the first read reaches the last three months only', (
    tester,
  ) async {
    final client = _FakeGroupClient();
    final now = DateTime.now();

    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();

    expect(client.lessonCalls, hasLength(1));
    expect(
      client.lessonCalls.single.from,
      DateTime(now.year, now.month - 2, 1),
    );
  });

  testWidgets('stepping four months back loads the months before the window', (
    tester,
  ) async {
    final client = _FakeGroupClient();
    final now = DateTime.now();

    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();

    for (var step = 1; step <= 4; step++) {
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // The calendar shows the month that was stepped to ...
      final shown = DateFormat.yMMMM('en')
          .format(DateTime(now.year, now.month - step));

      expect(find.text(shown), findsOneWidget, reason: 'step $step');
    }

    // ... and the window was extended to reach it.
    expect(client.lessonCalls, hasLength(2));
  });
}
