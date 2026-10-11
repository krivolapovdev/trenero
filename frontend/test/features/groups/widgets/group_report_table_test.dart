import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/widgets/group_report_table.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Anna was present on the first lesson day and missed the second one, Ivan the
/// other way round, and the third day had no lesson at all.
GroupReportResponse _report() => const GroupReportResponse(
  groupId: 'group-1',
  groupName: 'Group A',
  year: 2026,
  month: 2,
  dayCount: 3,
  lessonDays: [1, 2],
  students: [
    GroupReportStudentResponse(
      studentId: 'student-1',
      fullName: 'Anna Smirnova',
      paid: true,
      presentDays: [1],
      presentCount: 1,
      lessonCount: 2,
    ),
    GroupReportStudentResponse(
      studentId: 'student-2',
      fullName: 'Ivan Petrov',
      paid: false,
      presentDays: [2],
      presentCount: 1,
      lessonCount: 2,
    ),
  ],
  totalPresent: 2,
  totalLessons: 4,
);

Widget _wrap(GroupReportResponse report) => TranslationProvider(
  child: MaterialApp(
    home: Scaffold(body: GroupReportTable(report: report)),
  ),
);

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  testWidgets('renders a column for every day of the month', (tester) async {
    await tester.pumpWidget(_wrap(_report()));

    expect(find.text('№'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Result'), findsOneWidget);

    // Every day of the month gets its own column, including day 3 without a
    // lesson. The numbers 1 and 2 are reused as the row numbers of the two
    // students, so they appear twice.
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('3'), findsOneWidget);

    expect(find.text('Anna Smirnova'), findsOneWidget);
    expect(find.text('Ivan Petrov'), findsOneWidget);
  });

  testWidgets('marks every day and the payment state with + and -', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_report()));

    // Anna: present on day 1, absent on day 2 and paid. Ivan: absent on day 1,
    // present on day 2 and unpaid. The third day had no lesson, so it renders
    // no mark at all.
    expect(find.text('+'), findsNWidgets(3));
    expect(find.text('-'), findsNWidgets(3));
  });

  testWidgets('prints the per student result and the summed group result', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_report()));

    expect(find.text('1/2'), findsNWidgets(2));
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('2/4'), findsOneWidget);
  });

  testWidgets('gives every row a visible height', (tester) async {
    await tester.pumpWidget(_wrap(_report()));

    // Regression: with `TableCellVerticalAlignment.fill` on every cell the row
    // height collapses to zero, so the grid was laid out but entirely
    // invisible while every `find.text` assertion above still passed.
    expect(tester.getSize(find.byType(Table)).height, greaterThan(0));

    for (final text in ['Anna Smirnova', 'Ivan Petrov', 'Total', '+', '1/2']) {
      expect(
        tester.getRect(find.text(text).first).height,
        greaterThan(0),
        reason: '"$text" should be rendered with a visible height',
      );
    }
  });
}
