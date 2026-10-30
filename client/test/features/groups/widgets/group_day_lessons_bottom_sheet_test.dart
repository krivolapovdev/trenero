import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

final DateTime _day = DateTime(2026, 10, 8);

LessonResponse _lesson({String id = 'lesson-1'}) =>
    LessonResponse(id: id, date: _day, createdAt: _day, groupId: 'group-1');

final List<GroupDayLessonSelection?> _results = [];

Future<void> _openSheet(
  WidgetTester tester,
  GroupDayLessonsBottomSheet sheet,
) async {
  await tester.pumpWidget(
    ProviderScope(
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result =
                      await AppBottomSheet.show<GroupDayLessonSelection>(
                        context: context,
                        child: sheet,
                      );

                  _results.add(result);
                },
                child: const Text('open sheet'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open sheet'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  setUp(_results.clear);

  testWidgets('a day without lessons offers creating one', (tester) async {
    await _openSheet(tester, const GroupDayLessonsBottomSheet());

    expect(find.text(t.lessons.groupLesson), findsOneWidget);
    expect(find.text(t.lessons.groupLessons), findsNothing);
  });

  testWidgets('every lesson of the day is listed on its own', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(
        groupLessons: [
          _lesson(),
          _lesson(id: 'lesson-2'),
        ],
      ),
    );

    expect(find.text(t.lessons.groupLessons), findsNothing);
    expect(find.text('${t.lessons.groupLesson} 1'), findsOneWidget);
    expect(find.text('${t.lessons.groupLesson} 2'), findsOneWidget);

    expect(find.text(t.lessons.groupLesson), findsOneWidget);
  });

  testWidgets('a stored lesson is opened from the day sheet', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(groupLessons: [_lesson(id: 'lesson-2')]),
    );

    await tester.tap(find.text('${t.lessons.groupLesson} 1'));
    await tester.pumpAndSettle();

    expect(_results.single?.lesson?.id, 'lesson-2');
  });

  testWidgets('the create row opens a new lesson of the day', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(groupLessons: [_lesson()]),
    );

    await tester.tap(find.text(t.lessons.groupLesson));
    await tester.pumpAndSettle();

    expect(_results.single, isNotNull);
    expect(_results.single?.lesson, isNull);
  });

  testWidgets('lessons do not show attendance badges', (tester) async {
    await _openSheet(
      tester,
      GroupDayLessonsBottomSheet(groupLessons: [_lesson()]),
    );

    expect(find.byIcon(Icons.check), findsNothing);
  });
}
