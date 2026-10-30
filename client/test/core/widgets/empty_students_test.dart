import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/empty_students.dart';
import 'package:phone/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('renders empty students text centered with muted color', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(home: Scaffold(body: EmptyStudents())),
      ),
    );

    final textFinder = find.text(t.noStudents);
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.color, AppColors.mutedText);

    final paddingFinder = find.byType(Padding);
    expect(paddingFinder, findsOneWidget);
    final paddingWidget = tester.widget<Padding>(paddingFinder);
    expect(
      paddingWidget.padding,
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
    );
  });
}
