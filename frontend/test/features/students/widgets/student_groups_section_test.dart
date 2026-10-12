import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/features/students/widgets/student_groups_section.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

const _groupId = 'group-a';
const _studentId = 'student-1';

final _group = GroupResponse(
  id: _groupId,
  name: 'Group A',
  createdAt: DateTime(2025, 8, 22),
);

final _notedGroup = GroupResponse(
  id: 'group-b',
  name: 'Group B',
  createdAt: DateTime(2025, 8, 22),
  note: 'Bring the notebook',
);

final _listedGroups = [
  GroupSummaryResponse(
    id: _groupId,
    name: 'Group A',
    createdAt: DateTime(2025, 8, 22),
    countOfStudents: 4,
  ),
];

final _student = StudentSummaryResponse(
  id: _studentId,
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
  studentGroups: [_group],
);

final _studentInNotedGroup = StudentSummaryResponse(
  id: _studentId,
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
  studentGroups: [_notedGroup],
);

final _studentWithOneGroup = StudentSummaryResponse(
  id: _studentId,
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
  studentGroups: [_group],
);

final _studentWithoutGroup = StudentSummaryResponse(
  id: _studentId,
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
);

class _FakeGroupListController extends GroupListController {
  new(this.groups);

  final List<GroupSummaryResponse> groups;

  @override
  Future<List<GroupSummaryResponse>> build() async => groups;
}

Future<void> _pumpSection(
  WidgetTester tester,
  StudentSummaryResponse student, {
  List<GroupSummaryResponse> groups = const [],
  VoidCallback? onUpdate,
}) async {
  final container = ProviderContainer(
    overrides: [
      groupListControllerProvider.overrideWith(
        () => _FakeGroupListController(groups),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: StudentGroupsSection(student: student, onEdit: onUpdate),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the card titles the groups of the student', (tester) async {
    await _pumpSection(tester, _student, groups: _listedGroups);

    expect(find.text(t.groups.title), findsOneWidget);
    expect(find.byType(GroupCard), findsOneWidget);
    expect(find.text('Group A'), findsOneWidget);

    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('the card offers to update the groups of the student', (
    tester,
  ) async {
    var updated = false;

    await _pumpSection(
      tester,
      _student,
      groups: _listedGroups,
      onUpdate: () => updated = true,
    );

    await tester.tap(find.text(t.edit));
    await tester.pumpAndSettle();

    expect(updated, isTrue);
  });

  testWidgets('the card lists the group of a response that carries one', (
    tester,
  ) async {
    await _pumpSection(tester, _studentWithOneGroup);

    expect(find.text('Group A'), findsOneWidget);
  });

  testWidgets('a student without a group keeps no card', (tester) async {
    await _pumpSection(tester, _studentWithoutGroup, groups: _listedGroups);

    expect(find.text(t.groups.title), findsNothing);
    expect(find.byType(GroupCard), findsNothing);
  });

  testWidgets('the card hides the note of the group', (tester) async {
    await _pumpSection(tester, _studentInNotedGroup);

    expect(find.text('Group B'), findsOneWidget);
    expect(find.text('Bring the notebook'), findsNothing);
  });
}
