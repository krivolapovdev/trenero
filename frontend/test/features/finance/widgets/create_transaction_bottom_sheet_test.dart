import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
import 'package:phone/features/students/services/student_service.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/generated/student_controller/student_controller_client.dart';
import 'package:phone/i18n/strings.g.dart';

/// The create sheet loads the students to attribute a payment to; the fake
/// client serves [students] so the picker can be exercised.
class _FakeStudentClient implements StudentControllerClient {
  new([this.students = const []]);

  final List<StudentSummaryResponse> students;

  @override
  Future<List<StudentSummaryResponse>> getStudentsSummary() async => students;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The student the sheet is opened for.
final _student = StudentSummaryResponse(
  id: 'student-1',
  fullName: 'Anna Smirnova',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
);

/// Another student of the list, reachable only through the picker.
final _otherStudent = StudentSummaryResponse(
  id: 'student-2',
  fullName: 'Boris Petrov',
  createdAt: DateTime(2025, 8, 22),
  free: false,
  statuses: const [],
);

Widget _wrap({
  num? initialAmount,
  List<StudentSummaryResponse> students = const [],
  String? initialStudentName,
  bool isStudentLocked = false,
}) => ProviderScope(
  overrides: [
    studentServiceProvider.overrideWithValue(_FakeStudentClient(students)),
  ],
  child: TranslationProvider(
    child: MaterialApp(
      home: Scaffold(
        body: CreateTransactionBottomSheet(
          initialStudentId: 'student-1',
          initialStudentName: initialStudentName,
          initialAmount: initialAmount,
          isStudentLocked: isStudentLocked,
        ),
      ),
    ),
  ),
);

/// Pumps the sheet on a tall surface so every field is reachable by a tap.
Future<void> _pump(
  WidgetTester tester, {
  num? initialAmount,
  List<StudentSummaryResponse> students = const [],
  String? initialStudentName,
  bool isStudentLocked = false,
}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _wrap(
      initialAmount: initialAmount,
      students: students,
      initialStudentName: initialStudentName,
      isStudentLocked: isStudentLocked,
    ),
  );
  await tester.pumpAndSettle();
}

/// Mirrors the dd.MM.yyyy formatting used by the sheet.
String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

/// The digits of [date] without the dots, the way the user types them.
String _digits(DateTime date) => _formatDate(date).replaceAll('.', '');

/// The field whose floating label is [label].
Finder _field(String label) => find.widgetWithText(TextField, label);

/// The text currently shown by the field labelled [label].
String _textOf(WidgetTester tester, String label) =>
    tester.widget<TextField>(_field(label)).controller!.text;

/// The floating label of the date field.
String get _dateLabel => '${t.finance.date}*';

/// The floating label of the paid until field.
String get _paidUntilLabel => '${t.finance.paidUntil}*';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('the date field is prefilled with today', (tester) async {
    await _pump(tester);

    expect(find.text(_dateLabel), findsOneWidget);
    expect(_textOf(tester, _dateLabel), _formatDate(DateTime.now()));
  });

  testWidgets('the paid until field is prefilled one month ahead', (
    tester,
  ) async {
    await _pump(tester);

    final now = DateTime.now();
    final expected = DateTime(now.year, now.month + 1, now.day);

    expect(find.text(_paidUntilLabel), findsOneWidget);
    expect(_textOf(tester, _paidUntilLabel), _formatDate(expected));
  });

  testWidgets('the date fields are plain text fields, not calendars', (
    tester,
  ) async {
    await _pump(tester);

    for (final label in [_dateLabel, _paidUntilLabel]) {
      final field = tester.widget<TextField>(_field(label));

      expect(field.readOnly, isFalse, reason: label);
      expect(field.enabled, isTrue, reason: label);
    }
  });

  testWidgets('a typed paid until date is masked as dd.MM.yyyy', (
    tester,
  ) async {
    await _pump(tester);

    final now = DateTime.now();
    final target = DateTime(now.year, now.month + 1, 1);

    await tester.enterText(_field(_paidUntilLabel), _digits(target));
    await tester.pumpAndSettle();

    expect(_textOf(tester, _paidUntilLabel), _formatDate(target));
    expect(find.text(t.invalidDate), findsNothing);
  });

  testWidgets('an impossible paid until date blocks saving', (tester) async {
    await _pump(tester, initialAmount: 1000);

    await tester.enterText(_field(_paidUntilLabel), '99999999');
    await tester.pumpAndSettle();

    expect(_textOf(tester, _paidUntilLabel), '99.99.9999');
    expect(find.text(t.invalidDate), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, t.create))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a date after today is rejected and blocks saving', (
    tester,
  ) async {
    await _pump(tester, initialAmount: 1000);

    final later = DateTime.now().add(const Duration(days: 30));

    await tester.enterText(_field(_dateLabel), _digits(later));
    await tester.pumpAndSettle();

    expect(find.text(t.invalidDate), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, t.create))
          .onPressed,
      isNull,
    );
  });

  testWidgets('the student picker offers the other students by default', (
    tester,
  ) async {
    await _pump(tester, students: [_student, _otherStudent]);

    expect(find.text(_student.fullName), findsOneWidget);
    expect(find.text(_otherStudent.fullName), findsNothing);

    await tester.tap(find.text(_student.fullName));
    await tester.pumpAndSettle();

    expect(find.text(_otherStudent.fullName), findsOneWidget);
  });

  testWidgets('a locked sheet keeps the student of the page', (tester) async {
    await _pump(
      tester,
      students: [_student, _otherStudent],
      initialStudentName: _student.fullName,
      isStudentLocked: true,
    );

    expect(find.text(_student.fullName), findsOneWidget);

    await tester.tap(find.text(_student.fullName));
    await tester.pumpAndSettle();

    expect(find.text(_otherStudent.fullName), findsNothing);
    expect(find.text(t.students.noStudent), findsNothing);
  });

  testWidgets('a locked sheet shows the student before the list is loaded', (
    tester,
  ) async {
    await _pump(
      tester,
      initialStudentName: _student.fullName,
      isStudentLocked: true,
    );

    expect(find.text(_student.fullName), findsOneWidget);
  });
}
