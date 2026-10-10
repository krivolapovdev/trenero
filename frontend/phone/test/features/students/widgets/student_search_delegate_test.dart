import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/widgets/student_search_delegate.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

final _groups = [
  GroupSummaryResponse(
    id: 'group-a',
    name: 'Group A',
    createdAt: DateTime(2025, 8, 22),
  ),
];

final _students = [
  StudentSummaryResponse(
    id: 'student-1',
    fullName: 'Ivan Ivanov',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.paid],
    studentGroup: GroupResponse(
      id: 'group-a',
      name: 'Group A',
      createdAt: DateTime(2025, 8, 22),
    ),
  ),
  StudentSummaryResponse(
    id: 'student-2',
    fullName: 'Petr Sidorov',
    createdAt: DateTime(2025, 8, 22),
    free: false,
    statuses: const [StudentStatus.unpaid],
  ),
];

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => _groups;
}

Finder _optionTile(String label) => find.descendant(
  of: find.byType(CheckboxListTile),
  matching: find.text(label),
);

Future<void> _pumpSearchHost(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSearch(
                    context: context,
                    delegate: StudentSearchDelegate(_students, 'Search...'),
                  ),
                  child: const Text('open search'),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSearch(WidgetTester tester) async {
  await tester.tap(find.text('open search'));
  await tester.pumpAndSettle();
}

Future<void> _typeQuery(WidgetTester tester, String value) async {
  await tester.enterText(find.byType(TextField), value);
  await tester.pumpAndSettle();
}

Future<void> _selectGroupInFilterSheet(
  WidgetTester tester,
  String group,
) async {
  await tester.tap(find.byIcon(FluentIcons.filter_28_regular));
  await tester.pumpAndSettle();

  await tester.tap(_optionTile(group));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Apply'));
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

  testWidgets('the search screen exposes the filter button', (tester) async {
    await _pumpSearchHost(tester, container);
    await _openSearch(tester);

    expect(find.byIcon(FluentIcons.filter_28_regular), findsOneWidget);
    expect(find.text('Ivan Ivanov'), findsOneWidget);
    expect(find.text('Petr Sidorov'), findsOneWidget);
  });

  testWidgets('students are matched by name', (tester) async {
    await _pumpSearchHost(tester, container);
    await _openSearch(tester);

    await _typeQuery(tester, 'petr');

    expect(find.text('Petr Sidorov'), findsOneWidget);
    expect(find.text('Ivan Ivanov'), findsNothing);
  });

  testWidgets('the group filter narrows the search results', (tester) async {
    await _pumpSearchHost(tester, container);
    await _openSearch(tester);

    await _selectGroupInFilterSheet(tester, 'Group A');

    await _typeQuery(tester, 'ivan');

    expect(find.text('Ivan Ivanov'), findsOneWidget);
  });

  testWidgets('the group filter hides names that only match the query', (
    tester,
  ) async {
    await _pumpSearchHost(tester, container);
    await _openSearch(tester);

    await _selectGroupInFilterSheet(tester, 'Group A');

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isTrue);

    await _typeQuery(tester, 'petr');

    expect(find.text('Petr Sidorov'), findsNothing);
    expect(find.text('No students found'), findsOneWidget);
  });

  testWidgets('the filter can be reset from the empty search results', (
    tester,
  ) async {
    await _pumpSearchHost(tester, container);
    await _openSearch(tester);

    await _selectGroupInFilterSheet(tester, 'Group A');
    await _typeQuery(tester, 'petr');

    expect(find.text('No students found'), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();

    expect(find.text('Petr Sidorov'), findsOneWidget);
    expect(find.text('Ivan Ivanov'), findsNothing);

    final badge = tester.widget<Badge>(find.byType(Badge));
    expect(badge.isLabelVisible, isFalse);

    await _typeQuery(tester, '');

    expect(find.text('Ivan Ivanov'), findsOneWidget);
  });
}
