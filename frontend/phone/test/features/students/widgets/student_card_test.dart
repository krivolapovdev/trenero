import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/students/widgets/student_card.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

StudentSummaryResponse _student(String fullName) => StudentSummaryResponse(
  id: 'student-1',
  fullName: fullName,
  createdAt: DateTime(2026, 1, 15),
  free: false,
  statuses: const [],
);

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

/// The label drawn inside the circle avatar.
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

  // Regression: the group page numbers the students inside the displayed name,
  // so the derived initials picked the index up (`4. Nill Artmsh` -> `4N`).
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
}
