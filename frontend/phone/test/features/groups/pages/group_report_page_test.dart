import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/features/groups/pages/group_report_page.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/widgets/group_report_table.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

final GroupSummaryResponse _group = GroupSummaryResponse(
  id: 'group-1',
  name: 'Group A',
  createdAt: DateTime(2026, 1, 15),
);

/// Records the reported periods and answers them with a single student.
class _FakeGroupClient implements GroupControllerClient {
  final List<({int year, int month})> requestedPeriods = [];

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) async {
    requestedPeriods.add((year: year, month: month));

    return GroupReportResponse(
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
    child: MaterialApp(home: GroupReportPage(group: _group)),
  ),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('opens on the current month and renders the report table', (
    tester,
  ) async {
    final client = _FakeGroupClient();

    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();

    final now = DateTime.now();

    expect(client.requestedPeriods, [(year: now.year, month: now.month)]);
    expect(
      find.text(DateFormat.MMMM('en').format(DateTime(now.year, now.month))),
      findsOneWidget,
    );
    expect(find.text('${now.year}'), findsOneWidget);
    expect(find.byType(GroupReportTable), findsOneWidget);
    expect(find.text('Anna Smirnova'), findsOneWidget);
  });

  testWidgets('requests another month when the month popup changes', (
    tester,
  ) async {
    final client = _FakeGroupClient();

    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final nextMonth = now.month == 12 ? 1 : now.month + 1;

    await tester.tap(find.byType(PopupMenuButton<int>).last);
    await tester.pumpAndSettle();

    await tester.tap(
      find
          .text(DateFormat.MMMM('en').format(DateTime(now.year, nextMonth)))
          .last,
    );
    await tester.pumpAndSettle();

    expect(client.requestedPeriods.last, (year: now.year, month: nextMonth));
  });

  testWidgets('requests the selected year through the year popup', (
    tester,
  ) async {
    final client = _FakeGroupClient();

    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();

    // The picker offers the creation year of the group up to the next year.
    final nextYear = DateTime.now().year + 1;

    await tester.tap(find.byType(PopupMenuButton<int>).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('$nextYear').last);
    await tester.pumpAndSettle();

    expect(client.requestedPeriods.last.year, nextYear);
  });
}
