import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/students/widgets/student_form_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

Widget _wrap(Widget child, {VisualDensity? visualDensity}) =>
    TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(visualDensity: visualDensity),
        home: Scaffold(body: child),
      ),
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

/// The spot of [leaf] read from the top left corner of the [row] that holds
/// it, so that the spots of two rows can be compared.
Offset _spotIn(Rect row, Rect leaf) => leaf.topLeft - row.topLeft;

/// Checks that the free field is drawn as the phone field above it.
///
/// The row of the free field is as tall as the row of the phone field, so its
/// underline is drawn as far from its name as the underline of a field that
/// holds a value; the checkbox of the free field is read on the spot of the
/// icon of the phone field; and the name of the free field is read on the spot
/// of the label of the phone field.
void _expectFreeDrawnAsPhone(WidgetTester tester) {
  final fields = find.byType(InputDecorator);
  final phone = tester.getRect(fields.at(2));
  final free = tester.getRect(fields.at(4));

  expect(free.size, phone.size);
  expect(
    _spotIn(free, tester.getRect(find.byType(Checkbox))),
    _spotIn(phone, tester.getRect(find.byIcon(FluentIcons.call_16_regular))),
  );
  expect(
    _spotIn(free, tester.getRect(find.text(t.students.free))),
    _spotIn(phone, tester.getRect(find.text(t.students.phone))),
  );
}

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

    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.text(t.students.free), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.text(t.create));
    await tester.pump();

    expect(submittedFree, isTrue);
  });

  testWidgets('the row of the free field toggles it with a tap', (
    tester,
  ) async {
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

    await tester.enterText(find.byType(TextField).first, 'Ivan Petrov');
    // The name of the field is not a control, so the tap is read by the row.
    await tester.tap(find.text(t.students.free));
    await tester.pump();

    await tester.tap(find.text(t.create));
    await tester.pump();

    expect(submittedFree, isTrue);
  });

  testWidgets('the free field is drawn like the fields above it', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_sheet()));

    _expectFreeDrawnAsPhone(tester);
  });

  testWidgets(
    'the free field is drawn like the fields above it on a dense theme',
    (tester) async {
      // A dense theme draws the fields more tightly than the checkbox asks for.
      await tester.pumpWidget(
        _wrap(_sheet(), visualDensity: VisualDensity.comfortable),
      );

      _expectFreeDrawnAsPhone(tester);
    },
  );

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
