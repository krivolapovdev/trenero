import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/widgets/group_form_sheet.dart';
import 'package:phone/i18n/strings.g.dart';

Widget _wrap(Widget child) => TranslationProvider(
  child: MaterialApp(home: Scaffold(body: child)),
);

Widget _createSheet() => GroupFormSheet(
  title: t.groups.createGroup,
  submitLabel: t.create,
  onSubmit: ({
    required String name,
    required String priceText,
    required String note,
  }) async {},
);

/// The form of a stored group, opened the way the edit sheet opens it.
Widget _editSheet() => GroupFormSheet(
  title: t.groups.editGroup,
  submitLabel: t.update,
  initialName: 'Group A',
  initialPrice: '1500',
  initialNote: 'Note of the group',
  onSubmit: ({
    required String name,
    required String priceText,
    required String note,
  }) async {},
);

/// The action of the form.
TextButton _submit(WidgetTester tester) =>
    tester.widget<TextButton>(find.byType(TextButton));

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  testWidgets('the name alone allows creating a group', (tester) async {
    await tester.pumpWidget(_wrap(_createSheet()));

    expect(_submit(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Group A');
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);
  });

  testWidgets('the edit form waits for a field to change', (tester) async {
    await tester.pumpWidget(_wrap(_editSheet()));

    // Every field carries the stored value, so there is nothing to edit yet.
    expect(_submit(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Group B');
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);

    // Typing the stored name back leaves nothing to edit again.
    await tester.enterText(find.byType(TextField).first, 'Group A');
    await tester.pump();

    expect(_submit(tester).onPressed, isNull);
  });

  testWidgets('the edit form notices the price and the note', (tester) async {
    await tester.pumpWidget(_wrap(_editSheet()));

    await tester.enterText(find.byType(TextField).at(1), '2000');
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);

    await tester.enterText(find.byType(TextField).at(1), '1500');
    await tester.pump();

    expect(_submit(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(2), 'Another note');
    await tester.pump();

    expect(_submit(tester).onPressed, isNotNull);
  });
}
