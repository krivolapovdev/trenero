import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:phone/features/groups/services/group_report_pdf_service.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// February 2026: two lesson days, Anna present on the first one and paid.
GroupReportResponse _report({
  String groupName = 'Group A',
  String studentName = 'Anna Smirnova',
  int dayCount = 28,
}) => GroupReportResponse(
  groupId: 'group-1',
  groupName: groupName,
  year: 2026,
  month: 2,
  dayCount: dayCount,
  lessonDays: const [1, 2],
  students: [
    GroupReportStudentResponse(
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
);

/// The PDF is compressed, so only the plain dictionaries around the content can
/// be read back; the text itself is stored as glyph references of the embedded
/// font.
String _asText(Uint8List bytes) => latin1.decode(bytes);

/// Width and height of the first page, taken from its `MediaBox`.
List<double> _pageSize(String pdf) {
  final match = RegExp(r'/MediaBox\[([^\]]+)\]').firstMatch(pdf);

  expect(match, isNotNull, reason: 'the document should have a page size');

  return match!.group(1)!.split(' ').skip(2).map(double.parse).toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting();
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  final service = GroupReportPdfService();

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

    // Landscape A4: a column per day of the month only fits on its side.
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

    // Without the embedded Roboto the Cyrillic names would render as blanks.
    expect(text, contains('/FontName/Roboto-Regular'));
    expect(text, contains('/FontName/Roboto-Bold'));
  });

  test('names the printed document after the group and the reported month', () {
    expect(
      GroupReportPdfService.documentName(_report(groupName: 'Группа А')),
      'Группа А 2026-02.pdf',
    );
  });
}
