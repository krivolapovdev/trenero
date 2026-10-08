import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/students/widgets/student_form_sheet.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

GroupSummaryResponse _group({required String id, required String name}) =>
    GroupSummaryResponse(id: id, name: name, createdAt: DateTime(2025, 1, 1));

List<GroupSummaryResponse> _groups() => [
  _group(id: 'group-1', name: 'Beginners'),
  _group(id: 'group-2', name: 'Advanced'),
];

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

Widget _sheet({
  Future<void> Function({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
    required String? groupId,
  })?
  onSubmit,
  String? initialGroupId,
}) => StudentFormSheet(
  title: t.students.createStudent,
  submitLabel: t.create,
  submitIcon: Icons.add,
  groups: _groups(),
  initialGroupId: initialGroupId,
  onSubmit:
      onSubmit ??
      ({
        required String fullName,
        required DateTime? birthdate,
        required String? phone,
        required String? note,
        required String? groupId,
      }) async {},
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('group options are hidden until the group field is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_sheet()));

    expect(find.byIcon(FluentIcons.chevron_down_24_regular), findsOneWidget);
    expect(find.text(t.students.group), findsOneWidget);
    expect(find.text(t.groups.noGroup), findsOneWidget);
    expect(find.text('Beginners'), findsNothing);
    expect(find.text('Advanced'), findsNothing);
  });

  testWidgets('tapping the group field reveals the options and picking one '
      'collapses them back', (tester) async {
    await tester.pumpWidget(_wrap(_sheet()));

    await tester.tap(find.byIcon(FluentIcons.chevron_down_24_regular));
    await tester.pumpAndSettle();

    expect(find.byIcon(FluentIcons.chevron_up_24_regular), findsOneWidget);
    expect(find.text('Beginners'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
    // The field itself and the option under it.
    expect(find.text(t.groups.noGroup), findsNWidgets(2));

    await tester.tap(find.text('Beginners'));
    await tester.pumpAndSettle();

    expect(find.byIcon(FluentIcons.chevron_down_24_regular), findsOneWidget);
    // The picked group is displayed by the field, the options are gone.
    expect(find.text('Beginners'), findsOneWidget);
    expect(find.text('Advanced'), findsNothing);
    expect(find.text(t.groups.noGroup), findsNothing);
  });

  testWidgets('tapping another field collapses the group options', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_sheet()));

    await tester.tap(find.byIcon(FluentIcons.chevron_down_24_regular));
    await tester.pumpAndSettle();
    expect(find.text('Advanced'), findsOneWidget);

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.text('Advanced'), findsNothing);
  });

  testWidgets('the picked group is submitted with the form', (tester) async {
    String? submittedGroupId;

    await tester.pumpWidget(
      _wrap(
        _sheet(
          onSubmit:
              ({
                required String fullName,
                required DateTime? birthdate,
                required String? phone,
                required String? note,
                required String? groupId,
              }) async {
                submittedGroupId = groupId;
              },
        ),
      ),
    );

    await tester.tap(find.byIcon(FluentIcons.chevron_down_24_regular));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov');
    await tester.pump();

    await tester.tap(find.text(t.create));
    await tester.pump();

    expect(submittedGroupId, 'group-2');
  });

  testWidgets('an already assigned group is shown by the field', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_sheet(initialGroupId: 'group-1')));

    expect(find.text('Beginners'), findsOneWidget);
    expect(find.text(t.groups.noGroup), findsNothing);
  });
}
