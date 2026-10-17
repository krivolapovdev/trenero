import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

StudentSummaryResponse _student(String fullName) => StudentSummaryResponse(
  id: 'student-1',
  fullName: fullName,
  createdAt: DateTime(2026, 1, 15),
  free: false,
  statuses: const [],
);

StudentSummaryResponse _studentWithDetails() => StudentSummaryResponse(
  id: 'student-1',
  fullName: 'Anna Smirnova',
  birthdate: DateTime(1998, 6, 15),
  phone: '+7 999 123-45-67',
  createdAt: DateTime(2026, 1, 15),
  free: false,
  statuses: const [],
);

StudentSummaryResponse _studentWithGroups(List<String> names) =>
    StudentSummaryResponse(
      id: 'student-1',
      fullName: 'Anna Smirnova',
      createdAt: DateTime(2026, 1, 15),
      free: false,
      statuses: const [],
      studentGroups: [
        for (final name in names)
          GroupResponse(id: name, name: name, createdAt: DateTime(2026, 1, 15)),
      ],
    );

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

String _avatarLabel(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byType(CircleAvatar),
        matching: find.byType(Text),
      ),
    )
    .data!;

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the avatar derives the initials from the name', (tester) async {
    await tester.pumpWidget(
      _wrap(StudentCard(student: _student('Nill Artmsh'), onTap: () {})),
    );

    expect(_avatarLabel(tester), 'NA');
  });

  testWidgets('the override keeps the index out of the avatar', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StudentCard(
          student: _student('4. Nill Artmsh'),
          overrideInitials: 'NA',
          onTap: () {},
        ),
      ),
    );

    expect(find.text('4. Nill Artmsh'), findsOneWidget);
    expect(_avatarLabel(tester), 'NA');
  });

  testWidgets('the birthdate stays hidden unless it is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(StudentCard(student: _studentWithDetails(), onTap: () {})),
    );

    expect(find.text('15.06.1998'), findsNothing);
    expect(find.text('+7 999 123-45-67'), findsOneWidget);
  });

  testWidgets('the enabled birthdate is shown above the phone', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StudentCard(
          student: _studentWithDetails(),
          onTap: () {},
          showBirthdate: true,
        ),
      ),
    );

    expect(find.text('15.06.1998'), findsOneWidget);
    expect(find.text('+7 999 123-45-67'), findsOneWidget);
  });

  testWidgets('every group name is printed on its own line', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StudentCard(
          student: _studentWithGroups(['Group A', 'Group B']),
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Group A'), findsOneWidget);
    expect(find.text('Group B'), findsOneWidget);

    final firstGroup = tester.getTopLeft(find.text('Group A'));
    final secondGroup = tester.getTopLeft(find.text('Group B'));

    expect(secondGroup.dy, greaterThan(firstGroup.dy));
    expect(secondGroup.dx, equals(firstGroup.dx));
  });
}
