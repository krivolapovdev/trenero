import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/services/pdf_printer.dart';
import 'package:phone/features/students/controllers/student_report_controller.dart';
import 'package:phone/features/students/models/student_report.dart';
import 'package:phone/features/students/models/student_report_period.dart';
import 'package:phone/features/students/widgets/student_report_bottom_sheet.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

StudentSummaryResponse _student({DateTime? createdAt}) =>
    StudentSummaryResponse(
      id: 'student-1',
      fullName: 'Anna Smirnova',
      createdAt: createdAt ?? DateTime(DateTime.now().year, 1, 15),
      free: false,
      statuses: const [],
    );

final _recentStudent = _student();
final _oldStudent = _student(createdAt: DateTime(2000, 3));

final List<StudentReportPeriod> _requestedPeriods = [];

class _FakeStudentReportController extends StudentReportController {
  new(super.period);

  @override
  Future<StudentReport> build() async {
    _requestedPeriods.add(period);

    return StudentReport(
      studentId: period.studentId,
      fullName: 'Anna Smirnova',
      year: period.year,
      month: period.month,
      groups: [
        GroupReportResponse(
          groupId: 'group-a',
          groupName: 'Group A',
          year: period.year,
          month: period.month,
          dayCount: 28,
          lessonDays: const [1],
          students: [
            GroupReportStudentResponse(
              dayMarks: const [],
              studentId: period.studentId,
              fullName: 'Anna Smirnova',
              paid: true,
              presentDays: const [1],
              presentCount: 1,
              lessonCount: 1,
            ),
          ],
          totalPresent: 1,
          totalLessons: 1,
        ),
      ],
      individualLessons: [
        StudentReportLesson(
          date: DateTime(period.year, period.month, 3),
          present: true,
        ),
      ],
    );
  }
}

class _FakeLanguageNotifier extends LanguageNotifier {
  @override
  Future<AppLocale> build() async => AppLocale.en;
}

class _FakePdfPrinter implements PdfPrinter {
  final List<({Uint8List bytes, String name, PdfPageFormat format})> printed =
      [];

  @override
  Future<bool> print({
    required Uint8List bytes,
    required String name,
    required PdfPageFormat format,
  }) async {
    printed.add((bytes: bytes, name: name, format: format));
    return true;
  }
}

Widget _wrap({StudentSummaryResponse? student, PdfPrinter? printer}) =>
    ProviderScope(
      overrides: [
        studentReportProvider.overrideWith2(_FakeStudentReportController.new),
        languageProvider.overrideWith(_FakeLanguageNotifier.new),
        if (printer != null) pdfPrinterProvider.overrideWithValue(printer),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: StudentReportBottomSheet(student: student ?? _recentStudent),
          ),
        ),
      ),
    );

Finder _field(String label) => find.widgetWithText(TextField, label);

String _textOf(WidgetTester tester, String label) =>
    tester.widget<TextField>(_field(label)).controller!.text;

Future<void> _type(WidgetTester tester, String label, String value) async {
  await tester.enterText(_field(label), value);
  await tester.pumpAndSettle();
}

bool _canPrint(WidgetTester tester) =>
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, t.print))
        .onPressed !=
    null;

int _earlierMonth(DateTime now) =>
    now.month == DateTime.january ? 12 : now.month - 1;

int _earlierYear(DateTime now) =>
    now.month == DateTime.january ? now.year - 1 : now.year;

Future<void> _tapPrint(WidgetTester tester) async {
  await tester.tap(
    find.widgetWithText(TextButton, t.print),
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(_requestedPeriods.clear);

  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('opens on the current month and shows the print action', (
    tester,
  ) async {
    final now = DateTime.now();

    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(_textOf(tester, t.month), '${now.month}');
    expect(_textOf(tester, t.year), '${now.year}');
    expect(_requestedPeriods, [
      StudentReportPeriod(
        studentId: 'student-1',
        year: now.year,
        month: now.month,
      ),
    ]);
    expect(_canPrint(tester), isTrue);
  });

  testWidgets('asks again for the month that is typed in', (tester) async {
    final now = DateTime.now();
    final month = _earlierMonth(now);
    final year = _earlierYear(now);

    await tester.pumpWidget(_wrap(student: _oldStudent));
    await tester.pumpAndSettle();

    if (year != now.year) await _type(tester, t.year, '$year');
    await _type(tester, t.month, '$month');

    expect(
      _requestedPeriods.last,
      StudentReportPeriod(studentId: 'student-1', year: year, month: month),
    );
    expect(find.text(t.invalidDate), findsNothing);
    expect(_canPrint(tester), isTrue);
  });

  testWidgets('refuses a period that has not started yet', (tester) async {
    final now = DateTime.now();
    final printer = _FakePdfPrinter();

    await tester.pumpWidget(_wrap(printer: printer));
    await tester.pumpAndSettle();

    final laterMonth = now.month == DateTime.december ? 1 : now.month + 1;
    final laterYear = now.month == DateTime.december ? now.year + 1 : now.year;

    await _type(tester, t.year, '$laterYear');
    await _type(tester, t.month, '$laterMonth');

    expect(find.text(t.invalidDate), findsWidgets);
    expect(_canPrint(tester), isFalse);

    await _tapPrint(tester);
    expect(printer.printed, isEmpty);
  });

  testWidgets('refuses a year the student has no history for', (tester) async {
    await tester.pumpWidget(_wrap(student: _oldStudent));
    await tester.pumpAndSettle();

    await _type(tester, t.year, '1999');

    expect(find.text(t.invalidDate), findsOneWidget);
    expect(_canPrint(tester), isFalse);
  });

  testWidgets('prints the report of the typed month as a PDF', (tester) async {
    final printer = _FakePdfPrinter();
    final now = DateTime.now();
    final month = _earlierMonth(now);
    final year = _earlierYear(now);

    await tester.pumpWidget(_wrap(student: _oldStudent, printer: printer));
    await tester.pumpAndSettle();

    if (year != now.year) await _type(tester, t.year, '$year');
    await _type(tester, t.month, '$month');

    await _tapPrint(tester);

    expect(printer.printed, hasLength(1));

    final printed = printer.printed.single;

    expect(
      printed.name,
      'Anna Smirnova $year-${month.toString().padLeft(2, '0')}.pdf',
    );
    expect(
      String.fromCharCodes(printed.bytes.take(5)),
      '%PDF-',
      reason: 'the print action should hand over a PDF document',
    );
    expect(printed.bytes.length, greaterThan(1000));
    expect(
      printed.format.width,
      greaterThan(printed.format.height),
      reason: 'the report is printed on an album sheet',
    );
  });
}
