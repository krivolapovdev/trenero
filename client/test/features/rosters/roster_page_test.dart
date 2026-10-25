import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/rosters/pages/roster_details_page.dart';
import 'package:phone/features/rosters/pages/roster_list_page.dart';
import 'package:phone/features/rosters/services/roster_service.dart';
import 'package:phone/features/rosters/widgets/add_roster_students_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/edit_roster_student_bottom_sheet.dart';
import 'package:phone/features/rosters/widgets/roster_card.dart';
import 'package:phone/features/rosters/widgets/roster_student_list_view.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/export.dart';
import 'package:phone/i18n/strings.g.dart';

class _FakeRosterClient implements RosterControllerClient {
  final List<RosterResponse> rosters;
  final List<StudentResponse> students;

  new({required this.rosters, required this.students});

  @override
  Future<List<RosterResponse>> getAllRosters() async => rosters;

  @override
  Future<RosterResponse> getRosterById({required String rosterId}) async =>
      rosters.firstWhere((r) => r.id == rosterId);

  @override
  Future<List<StudentResponse>> getRosterStudents({
    required String rosterId,
  }) async => students;

  @override
  Future<RosterResponse> createRoster({
    required CreateRosterRequest body,
  }) async => RosterResponse(
    id: 'new-roster',
    name: body.name,
    note: body.note,
    date: body.date,
    createdAt: DateTime.now(),
    countOfStudents: 0,
  );

  @override
  Future<RosterResponse> updateRoster({
    required String rosterId,
    required Map<String, dynamic> body,
  }) async => rosters.firstWhere((r) => r.id == rosterId);

  @override
  Future<void> deleteRoster({required String rosterId}) async {}

  @override
  Future<RosterResponse> addStudentsToRoster({
    required String rosterId,
    required AddRosterStudentsRequest body,
  }) async => rosters.firstWhere((r) => r.id == rosterId);

  @override
  Future<void> updateRosterStudentNote({
    required String rosterId,
    required String studentId,
    required Map<String, dynamic> body,
  }) async {}

  @override
  Future<void> removeStudentFromRoster({
    required String rosterId,
    required String studentId,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStudentClient implements StudentControllerClient {
  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrap({
  required Widget child,
  required List<RosterResponse> rosters,
  required List<StudentResponse> students,
}) => ProviderScope(
  overrides: [
    rosterServiceProvider.overrideWithValue(
      _FakeRosterClient(rosters: rosters, students: students),
    ),
    studentServiceProvider.overrideWithValue(_FakeStudentClient()),
  ],
  child: TranslationProvider(child: MaterialApp(home: child)),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  final testRoster = RosterResponse(
    id: 'roster-1',
    name: 'Morning Swim Group',
    note: 'Temporary roster for pool maintenance day',
    date: DateTime(2026, 10, 23),
    createdAt: DateTime(2026, 10, 23),
    countOfStudents: 2,
  );

  final testStudent = StudentResponse(
    id: 'student-1',
    fullName: 'Alex Johnson',
    phone: '+1 555 123 4567',
    note: 'Special medical condition',
    createdAt: DateTime(2026, 10, 20),
    free: false,
  );

  testWidgets('RosterListPage renders title with count and roster cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        child: const RosterListPage(),
        rosters: [testRoster],
        students: [testStudent],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Temporary rosters: 1'), findsOneWidget);
    expect(find.text('Morning Swim Group: 2'), findsOneWidget);
    expect(
      find.text('Temporary roster for pool maintenance day'),
      findsOneWidget,
    );
    expect(find.byType(RosterCard), findsOneWidget);
  });

  testWidgets('Long press on roster card opens EditRosterBottomSheet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        child: const RosterListPage(),
        rosters: [testRoster],
        students: [testStudent],
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Morning Swim Group: 2'));
    await tester.pumpAndSettle();

    expect(
      find.text(LocaleSettings.instance.currentTranslations.rosters.editRoster),
      findsOneWidget,
    );
  });

  testWidgets('Tapping on a roster opens RosterDetailsPage with student list', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        child: const RosterListPage(),
        rosters: [testRoster],
        students: [testStudent],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morning Swim Group: 2'));
    await tester.pumpAndSettle();

    expect(find.byType(RosterDetailsPage), findsOneWidget);
    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('Special medical condition'), findsOneWidget);
  });

  testWidgets('Popup menu in RosterDetailsPage has edit and delete items', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        child: RosterDetailsPage(roster: testRoster),
        rosters: [testRoster],
        students: [testStudent],
      ),
    );
    await tester.pumpAndSettle();

    // Tap AppBar popup menu button
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(PopupMenuItem<String>),
        matching: find.text(LocaleSettings.instance.currentTranslations.edit),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(PopupMenuItem<String>),
        matching: find.text(LocaleSettings.instance.currentTranslations.delete),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(PopupMenuItem<String>),
        matching: find.text(
          LocaleSettings.instance.currentTranslations.students.title,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'Student item in RosterDetailsPage has more_vert icon that opens EditRosterStudentBottomSheet',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: RosterDetailsPage(roster: testRoster),
          rosters: [testRoster],
          students: [testStudent],
        ),
      );
      await tester.pumpAndSettle();

      final moreVert = find.descendant(
        of: find.byType(ListView),
        matching: find.byIcon(Icons.more_vert),
      );
      expect(moreVert, findsOneWidget);

      await tester.tap(moreVert);
      await tester.pumpAndSettle();

      expect(find.byType(EditRosterStudentBottomSheet), findsOneWidget);
      expect(
        find.text(LocaleSettings.instance.currentTranslations.delete),
        findsOneWidget,
      );
      expect(
        find.text(LocaleSettings.instance.currentTranslations.update),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Long press on student item in RosterDetailsPage opens EditRosterStudentBottomSheet',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: RosterDetailsPage(roster: testRoster),
          rosters: [testRoster],
          students: [testStudent],
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Alex Johnson'));
      await tester.pumpAndSettle();

      expect(find.byType(EditRosterStudentBottomSheet), findsOneWidget);
      expect(
        find.text(LocaleSettings.instance.currentTranslations.delete),
        findsOneWidget,
      );
      expect(
        find.text(LocaleSettings.instance.currentTranslations.update),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Long press on roster title in RosterDetailsPage opens EditRosterBottomSheet',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          child: RosterDetailsPage(roster: testRoster),
          rosters: [testRoster],
          students: [testStudent],
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Morning Swim Group'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          LocaleSettings.instance.currentTranslations.rosters.editRoster,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'RosterStudentListView does not render default student note when roster note is null',
    (tester) async {
      final studentWithoutNote = StudentResponse(
        id: 'student-2',
        fullName: 'Jane Doe',
        note: null,
        createdAt: DateTime(2026, 10, 20),
        free: false,
      );
      final defaultStudentSummary = StudentSummaryResponse(
        id: 'student-2',
        fullName: 'Jane Doe',
        note: 'Default general student note',
        createdAt: DateTime(2026, 10, 20),
        free: false,
        statuses: const [],
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: RosterStudentListView(
                students: [studentWithoutNote],
                fullSummaries: [defaultStudentSummary],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Default general student note'), findsNothing);
    },
  );

  testWidgets(
    'RosterStudentListView handles duplicate students without key collision',
    (tester) async {
      final duplicateStudent1 = StudentResponse(
        id: 'student-1',
        fullName: 'Alexey Ivanov',
        free: false,
        createdAt: DateTime.now(),
        note: 'Heat 1',
      );
      final duplicateStudent2 = StudentResponse(
        id: 'student-1',
        fullName: 'Alexey Ivanov',
        free: false,
        createdAt: DateTime.now(),
        note: 'Heat 2',
      );

      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: RosterStudentListView(
                students: [duplicateStudent1, duplicateStudent2],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alexey Ivanov'), findsNWidgets(2));
      expect(find.text('Heat 1'), findsOneWidget);
      expect(find.text('Heat 2'), findsOneWidget);
    },
  );

  testWidgets('RosterStudentListView renders student item and note', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(body: RosterStudentListView(students: [testStudent])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('Special medical condition'), findsOneWidget);
  });

  testWidgets('AddRosterStudentsBottomSheet includes Note field', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        child: const Scaffold(
          body: AddRosterStudentsBottomSheet(
            rosterId: 'roster-1',
            existingStudentIds: {},
          ),
        ),
        rosters: [testRoster],
        students: [testStudent],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(LocaleSettings.instance.currentTranslations.note),
      findsOneWidget,
    );
  });
}
