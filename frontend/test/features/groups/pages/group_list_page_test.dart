import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/controllers/group_students_controller.dart';
import 'package:phone/features/groups/pages/group_list_page.dart';
import 'package:phone/features/groups/widgets/group_list_view.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

final _groups = [
  GroupSummaryResponse(
    id: 'group-1',
    name: 'Group A',
    createdAt: DateTime(2025, 8, 22),
    countOfStudents: 1,
  ),
];

class _FakeGroupListController extends GroupListController {
  @override
  Future<List<GroupSummaryResponse>> build() async => _groups;

  @override
  Future<void> getAllGroups({bool forceRefresh = false}) async {
    state = AsyncData(_groups);
  }
}

/// Records every build of a group page family, so a test can tell whether the
/// cached data of the group pages was dropped.
class _FakeGroupLessonsController extends GroupLessonsController {
  new(super.groupId, this.builds);

  final List<String> builds;

  @override
  Future<List<LessonResponse>> build() async {
    builds.add(groupId);

    return const [];
  }
}

class _FakeGroupStudentsController extends GroupStudentsController {
  new(super.groupId, this.builds);

  final List<String> builds;

  @override
  Future<List<GroupStudentSummaryResponse>> build() async {
    builds.add(groupId);

    return const [];
  }
}

Future<void> _pumpGroupListPage(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final page = GroupListPage(title: 'Groups');

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Groups'),
                actions: page.actions(context),
              ),
              body: page,
            ),
          ),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _pullToRefresh(WidgetTester tester) async {
  await tester.fling(
    find.byType(GroupListView),
    const Offset(0.0, 300.0),
    1000.0,
  );
  await tester.pumpAndSettle();
}

void main() {
  late ProviderContainer container;
  late List<String> lessonsBuilds;
  late List<String> studentsBuilds;

  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  setUp(() {
    lessonsBuilds = [];
    studentsBuilds = [];

    container = ProviderContainer(
      overrides: [
        groupListControllerProvider.overrideWith(_FakeGroupListController.new),
        groupLessonsProvider.overrideWith2(
          (groupId) => _FakeGroupLessonsController(groupId, lessonsBuilds),
        ),
        groupStudentsProvider.overrideWith2(
          (groupId) => _FakeGroupStudentsController(groupId, studentsBuilds),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets('the list shows the groups of the controller', (tester) async {
    await _pumpGroupListPage(tester, container);

    expect(find.text('Group A'), findsOneWidget);
  });

  testWidgets('a pull to refresh drops the caches of the group pages', (
    tester,
  ) async {
    // Warm the caches the way opening a group page does.
    await container.read(groupLessonsProvider('group-1').future);
    await container.read(groupStudentsProvider('group-1').future);

    expect(lessonsBuilds, ['group-1']);
    expect(studentsBuilds, ['group-1']);

    await _pumpGroupListPage(tester, container);
    await _pullToRefresh(tester);

    // The caches are gone, so reading again builds the family once more.
    await container.read(groupLessonsProvider('group-1').future);
    await container.read(groupStudentsProvider('group-1').future);

    expect(lessonsBuilds, ['group-1', 'group-1']);
    expect(studentsBuilds, ['group-1', 'group-1']);
  });
}
