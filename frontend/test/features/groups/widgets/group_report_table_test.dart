import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/widgets/group_report_table.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

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
