import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/services/pdf_printer.dart';
import 'package:phone/features/groups/services/group_service.dart';
import 'package:phone/features/groups/widgets/group_report_bottom_sheet.dart';
import 'package:phone/generated/group_controller/group_controller_client.dart';
import 'package:phone/generated/models/create_group_request.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';

final GroupSummaryResponse _group = GroupSummaryResponse(
  id: 'group-1',
  name: 'Group A',
  createdAt: DateTime(DateTime.now().year, 1, 15),
);

final GroupSummaryResponse _oldGroup = GroupSummaryResponse(
  id: 'group-1',
  name: 'Group A',
  createdAt: DateTime(2000, 3),
);

class _FakeGroupClient implements GroupControllerClient {
  final List<({int year, int month})> requestedPeriods = [];

  @override
  Future<GroupReportResponse> getGroupReport({
    required String groupId,
    required int year,
    required int month,
  }) async {
    requestedPeriods.add((year: year, month: month));

    return GroupReportResponse(
      groupId: groupId,
      groupName: _group.name,
      year: year,
      month: month,
      dayCount: DateTime(year, month + 1, 0).day,
      lessonDays: const [1, 2],
      students: const [
        GroupReportStudentResponse(
          dayMarks: [],
          studentId: 'student-1',
          fullName: 'Anna Smirnova',
          paid: true,
          presentDays: [1],
          presentCount: 1,
          lessonCount: 2,
        ),
      ],
      totalPresent: 1,
      totalLessons: 2,
    );
  }

  @override
  Future<List<GroupSummaryResponse>> getAllGroupsSummary() =>
      throw UnimplementedError();

  @override
  Future<GroupResponse> createGroup({required CreateGroupRequest body}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteGroup({required String groupId}) =>
      throw UnimplementedError();

  @override
  Future<List<LessonResponse>> getGroupLessons({
    required String groupId,
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError();

  @override
  Future<List<GroupStudentSummaryResponse>> getGroupStudents({
    required String groupId,
  }) => throw UnimplementedError();

  @override
  Future<GroupResponse> updateGroup({
    required String groupId,
    required Map<String, dynamic> body,
  }) => throw UnimplementedError();
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

Widget _wrap(
  _FakeGroupClient client, {
  GroupSummaryResponse? group,
  PdfPrinter? printer,
}) => ProviderScope(
  overrides: [
    groupServiceProvider.overrideWithValue(client),
    languageProvider.overrideWith(_FakeLanguageNotifier.new),
    if (printer != null) pdfPrinterProvider.overrideWithValue(printer),
  ],
  child: TranslationProvider(
    child: MaterialApp(
      home: Scaffold(body: GroupReportBottomSheet(group: group ?? _group)),
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
  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('opens on the current month and shows the print action', (
    tester,
  ) async {
    final client = _FakeGroupClient();
    final now = DateTime.now();

    await tester.pumpWidget(_wrap(client));
    await tester.pumpAndSettle();

    expect(client.requestedPeriods, [(year: now.year, month: now.month)]);
    expect(_textOf(tester, t.month), '${now.month}');
    expect(_textOf(tester, t.year), '${now.year}');
    expect(_canPrint(tester), isTrue);
  });

  testWidgets('asks again for the month that is typed in', (tester) async {
    final client = _FakeGroupClient();
    final now = DateTime.now();

    await tester.pumpWidget(_wrap(client, group: _oldGroup));
    await tester.pumpAndSettle();

    if (_earlierYear(now) != now.year) {
      await _type(tester, t.year, '${_earlierYear(now)}');
    }
    await _type(tester, t.month, '${_earlierMonth(now)}');

    expect(client.requestedPeriods.last, (
      year: _earlierYear(now),
      month: _earlierMonth(now),
    ));
    expect(find.text(t.invalidDate), findsNothing);
    expect(_canPrint(tester), isTrue);
  });

  testWidgets('refuses a period that has not started yet', (tester) async {
    final now = DateTime.now();
    final printer = _FakePdfPrinter();

    await tester.pumpWidget(_wrap(_FakeGroupClient(), printer: printer));
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

  testWidgets('refuses a year the group has no history for', (tester) async {
    final printer = _FakePdfPrinter();

    await tester.pumpWidget(
      _wrap(_FakeGroupClient(), group: _oldGroup, printer: printer),
    );
    await tester.pumpAndSettle();

    await _type(tester, t.year, '1999');

    expect(find.text(t.invalidDate), findsOneWidget);
    expect(_canPrint(tester), isFalse);
  });

  testWidgets('already refuses a month that is not a month', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await _type(tester, t.month, '13');

    expect(find.text(t.invalidDate), findsOneWidget);
    expect(_canPrint(tester), isFalse);
  });

  testWidgets('waits for a complete year before it complains', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGroupClient()));
    await tester.pumpAndSettle();

    await _type(tester, t.year, '20');

    expect(find.text(t.invalidDate), findsNothing);
    expect(_canPrint(tester), isFalse);
  });

  testWidgets('prints the report of the typed month as a PDF', (tester) async {
    final client = _FakeGroupClient();
    final printer = _FakePdfPrinter();
    final now = DateTime.now();
    final month = _earlierMonth(now);
    final year = _earlierYear(now);

    await tester.pumpWidget(_wrap(client, group: _oldGroup, printer: printer));
    await tester.pumpAndSettle();

    if (year != now.year) await _type(tester, t.year, '$year');
    await _type(tester, t.month, '$month');

    await _tapPrint(tester);

    expect(printer.printed, hasLength(1));

    final printed = printer.printed.single;

    expect(
      printed.name,
      'Group A $year-${month.toString().padLeft(2, '0')}.pdf',
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

  testWidgets('prints the current month without touching the fields', (
    tester,
  ) async {
    final printer = _FakePdfPrinter();
    final now = DateTime.now();

    await tester.pumpWidget(_wrap(_FakeGroupClient(), printer: printer));
    await tester.pumpAndSettle();

    await _tapPrint(tester);

    expect(
      printer.printed.single.name,
      'Group A ${now.year}-${now.month.toString().padLeft(2, '0')}.pdf',
    );
  });
}
