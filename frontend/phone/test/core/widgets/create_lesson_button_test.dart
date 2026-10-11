import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/create_lesson_button.dart';
import 'package:phone/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the button carries the create action of a lesson', (
    tester,
  ) async {
    var pressed = false;

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: CreateLessonButton(onPressed: () => pressed = true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.create), findsOneWidget);

    await tester.tap(find.byType(CreateLessonButton));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });
}
