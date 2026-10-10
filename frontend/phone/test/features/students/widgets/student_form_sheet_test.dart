import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/students/widgets/student_form_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

Widget _sheet({
  Future<void> Function({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
    required bool free,
  })?
  onSubmit,
}) => StudentFormSheet(
  title: t.students.createStudent,
  submitLabel: t.create,
  submitIcon: Icons.add,
  onSubmit:
      onSubmit ??
      ({
        required String fullName,
        required DateTime? birthdate,
        required String? phone,
        required String? note,
        required bool free,
      }) async {},
);

/// The form of a stored student, opened the way the edit sheet opens it.
Widget _editSheet() => StudentFormSheet(
  title: t.students.editStudent,
  submitLabel: t.edit,
  submitIcon: Icons.check,
  initialFullName: 'Ivan Petrov',
  initialBirthdate: DateTime(2010, 5, 20),
  initialPhone: '+7 999 123-45-67',
  initialNote: 'Note of the student',
  onSubmit: ({
    required String fullName,
    required DateTime? birthdate,
    required String? phone,
    required String? note,
    required bool free,
  }) async {},
);

/// The action of the form.
TextButton _submit(WidgetTester tester) =>
    tester.widget<TextButton>(find.byType(TextButton));

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the group field is not part of the student form anymore', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_sheet()));

    expect(find.text(t.students.group), findsNothing);
    expect(find.text(t.groups.noGroup), findsNothing);
  });

  testWidgets('the name is required to submit the form', (tester) async {
    await tester.pumpWidget(_wrap(_sheet()));

    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov');
    await tester.pump();

    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('the filled fields are submitted with the form', (tester) async {
    String? submittedName;
    String? submittedPhone;
    String? submittedNote;
    bool? submittedFree;

    await tester.pumpWidget(
      _wrap(
        _sheet(
          onSubmit:
              ({
                required String fullName,
                required DateTime? birthdate,
                required String? phone,
                required String? note,
                required bool free,
              }) async {
                submittedName = fullName;
                submittedPhone = phone;
                submittedNote = note;
                submittedFree = free;
              },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov');
    await tester.enterText(find.byType(TextField).at(2), '+7 999 123-45-67');
    await tester.enterText(find.byType(TextField).at(3), 'Note of the student');
    await tester.pump();

    await tester.tap(find.text(t.create));
    await tester.pump();

    expect(submittedName, 'Ivan Petrov');
    expect(submittedPhone, '+7 999 123-45-67');
    expect(submittedNote, 'Note of the student');
    expect(submittedFree, isFalse);
  });

  testWidgets('the free checkbox is submitted with the form', (tester) async {
    bool? submittedFree;

    await tester.pumpWidget(
      _wrap(
        _sheet(
          onSubmit:
              ({
                required String fullName,
                required DateTime? birthdate,
                required String? phone,
                required String? note,
                required bool free,
              }) async {
                submittedFree = free;
              },
        ),
      ),
    );

    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.text(t.students.free), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.text(t.create));
    await tester.pump();

    expect(submittedFree, isTrue);
  });

  testWidgets('the edit form waits for a field to change', (tester) async {
    await tester.pumpWidget(_wrap(_editSheet()));

    // Every field carries the stored value, so there is nothing to edit yet.
    expect(_submit(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov Jr.');
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);

    // Typing the stored name back leaves nothing to edit again.
    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov');
    await tester.pump();

    expect(_submit(tester).onPressed, isNull);
  });

  testWidgets('the edit form notices the phone and the note', (tester) async {
    await tester.pumpWidget(_wrap(_editSheet()));

    await tester.enterText(find.byType(TextField).at(2), '+7 999 000-00-00');
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);

    await tester.enterText(find.byType(TextField).at(2), '+7 999 123-45-67');
    await tester.pump();

    expect(_submit(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(3), 'Another note');
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);
  });

  testWidgets('the edit form notices the free checkbox', (tester) async {
    await tester.pumpWidget(_wrap(_editSheet()));

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);
  });
}
