import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/controllers/student_filter_controller.dart';
import 'package:phone/features/students/models/student_filter.dart';
import 'package:phone/features/students/widgets/student_filter_bottom_sheet.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/i18n/strings.g.dart';

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => [
    GroupSummaryResponse(
      id: 'group-1',
      name: 'Group A',
      createdAt: DateTime(2025, 8, 22),
    ),
  ];
}

Future<void> _openSheet(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AppBottomSheet.show(
                  context: context,
                  child: const StudentFilterBottomSheet(),
                ),
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
  late ProviderContainer container;

  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  setUp(() {
    container = ProviderContainer(
      overrides: [
        groupListControllerProvider.overrideWith(_FakeGroupListController.new),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('tapping reset clears the filter and closes the sheet', (
    tester,
  ) async {
    container
        .read(studentFilterControllerProvider.notifier)
        .setFilter(
          const StudentFilter(
            groupIds: {'group-1'},
            statuses: {StudentStatus.paid},
          ),
        );

    await _openSheet(tester, container);

    expect(find.text(t.students.filter.title), findsOneWidget);

    await tester.tap(find.text(t.reset));
    await tester.pumpAndSettle();

    expect(find.text(t.students.filter.title), findsNothing);
    expect(container.read(studentFilterControllerProvider).isEmpty, isTrue);
  });
}
