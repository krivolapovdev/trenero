import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/students/models/student_report.dart';
import 'package:phone/features/students/services/student_report_pdf_service.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

StudentReport _report({
  String groupName = 'Group A',
  String studentName = 'Anna Smirnova',
  int dayCount = 28,
}) => StudentReport(
  studentId: 'student-1',
  fullName: studentName,
  year: 2026,
  month: 2,
  groups: [
    GroupReportResponse(
      groupId: 'group-a',
      groupName: groupName,
      year: 2026,
      month: 2,
      dayCount: dayCount,
      lessonDays: const [1, 2],
      students: [
        GroupReportStudentResponse(
          dayMarks: const [],
          studentId: 'student-1',
          fullName: studentName,
          paid: true,
          presentDays: const [1],
          presentCount: 1,
          lessonCount: 2,
        ),
      ],
      totalPresent: 1,
      totalLessons: 2,
    ),
    GroupReportResponse(
      groupId: 'group-b',
      groupName: 'Group B',
      year: 2026,
      month: 2,
      dayCount: dayCount,
      lessonDays: const [3],
      students: [
        GroupReportStudentResponse(
          dayMarks: const [],
          studentId: 'student-1',
          fullName: studentName,
          paid: false,
          presentDays: const [],
          presentCount: 0,
          lessonCount: 1,
        ),
      ],
      totalPresent: 0,
      totalLessons: 1,
    ),
  ],
  individualLessons: [
    StudentReportLesson(date: DateTime(2026, 2, 3), present: true),
    StudentReportLesson(date: DateTime(2026, 2, 10), present: false),
  ],
);

String _asText(Uint8List bytes) => latin1.decode(bytes);

List<double> _pageSize(String pdf) {
  final match = RegExp(r'/MediaBox\[([^\]]+)\]').firstMatch(pdf);

  expect(match, isNotNull, reason: 'the document should have a page size');

  return match!.group(1)!.split(' ').skip(2).map(double.parse).toList();
}

String _pageContent(Uint8List bytes) {
  final text = latin1.decode(bytes);
  final buffer = StringBuffer();
  var index = 0;

  while (true) {
    final start = text.indexOf('stream', index);
    if (start < 0) break;

    var dataStart = start + 'stream'.length;
    if (text[dataStart] == '\r') dataStart++;
    if (text[dataStart] == '\n') dataStart++;

    final end = text.indexOf('endstream', dataStart);
    if (end < 0) break;

    final raw = bytes.sublist(dataStart, end);
    for (final candidate in [
      raw,
      Uint8List.sublistView(raw, 0, raw.length - 1),
      Uint8List.sublistView(raw, 0, raw.length - 2),
    ]) {
      try {
        buffer.writeln(latin1.decode(zlib.decode(candidate)));
        break;
      } catch (_) {
        continue;
      }
    }

    index = end + 'endstream'.length;
  }

  return buffer.toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  final service = StudentReportPdfService();

  test('builds a printable PDF of the report', () async {
    final bytes = await service.build(
      _report(),
      t: LocaleSettings.instance.currentTranslations,
      locale: 'en',
    );

    final text = _asText(bytes);

    expect(text, startsWith('%PDF-1.'));
    expect(text.trimRight(), endsWith('%%EOF'));
    expect(bytes.length, greaterThan(1000));

    final page = _pageSize(text);
    expect(page, hasLength(2));
    expect(page[0], closeTo(841.89, 0.01));
    expect(page[1], closeTo(595.28, 0.01));
  });

  test('fits every month of the year on a single page', () async {
    for (final dayCount in [28, 29, 30, 31]) {
      final bytes = await service.build(
        _report(dayCount: dayCount),
        t: LocaleSettings.instance.currentTranslations,
        locale: 'en',
      );

      expect(
        _asText(bytes),
        contains('/Count 1'),
        reason: 'a $dayCount day month should not spill over to a second page',
      );
    }
  });

  test('embeds the bundled font so that Cyrillic names are drawn', () async {
    final bytes = await service.build(
      _report(groupName: 'Группа А', studentName: 'Анна Смирнова'),
      t: LocaleSettings.instance.currentTranslations,
      locale: 'ru',
    );

    final text = _asText(bytes);

    expect(text, startsWith('%PDF-1.'));
    expect(bytes.length, greaterThan(1000));

    expect(text, contains('/FontName/Roboto-Regular'));
    expect(text, contains('/FontName/Roboto-Bold'));
  });

  test('names the printed document after the student and the month', () {
    expect(
      StudentReportPdfService.documentName(
        _report(studentName: 'Анна Смирнова'),
      ),
      'Анна Смирнова 2026-02.pdf',
    );
  });

  test('draws the check and the cross as strokes, not as characters', () async {
    final bytes = await service.build(
      _report(),
      t: LocaleSettings.instance.currentTranslations,
      locale: 'en',
    );

    final content = _pageContent(bytes);

    expect(content, contains('1 4.6 m 3.2 2 l 8 7.4 l S'));
    expect(content, contains('1.4 1.4 m 7.6 7.6 l 7.6 1.4 m 1.4 7.6 l S'));
    expect(content, contains('1 J 1 j'), reason: 'the marks are rounded');
  });
}
