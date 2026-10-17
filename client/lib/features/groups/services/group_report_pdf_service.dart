import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

final groupReportPdfServiceProvider = Provider<GroupReportPdfService>(
  (ref) => GroupReportPdfService(),
);

class GroupReportPdfService {
  static const String regularFontAsset = 'assets/fonts/Roboto-Regular.ttf';
  static const String boldFontAsset = 'assets/fonts/Roboto-Bold.ttf';

  static const PdfPageFormat pageFormat = PdfPageFormat(
    297 * PdfPageFormat.mm,
    210 * PdfPageFormat.mm,
    marginAll: 10 * PdfPageFormat.mm,
  );

  static const double _markSize = 9;
  static const double _markStroke = 1.3;

  static const PdfColor _presentColor = PdfColors.green800;
  static const PdfColor _missingColor = PdfColors.red800;

  static const double _numberWidth = 26;
  static const double _nameWidth = 150;
  static const double _paidWidth = 44;
  static const double _resultWidth = 54;

  static const double _maxDayWidth = 20;
  static const double _cellPadding = 2;
  static const double _cellHeight = 18;

  static const pw.TableBorder _border = pw.TableBorder(
    top: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
    bottom: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
    left: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
    right: pw.BorderSide(color: PdfColors.grey700, width: 0.5),
    horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.3),
    verticalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.3),
  );

  static const pw.TextStyle _headerStyle = pw.TextStyle(
    fontSize: 7,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.grey700,
  );
  static const pw.TextStyle _cellStyle = pw.TextStyle(fontSize: 7.5);
  static const pw.TextStyle _totalStyle = pw.TextStyle(
    fontSize: 7.5,
    fontWeight: pw.FontWeight.bold,
  );
  static const pw.TextStyle _titleStyle = pw.TextStyle(
    fontSize: 15,
    fontWeight: pw.FontWeight.bold,
  );
  static const pw.TextStyle _subtitleStyle = pw.TextStyle(
    fontSize: 10,
    color: PdfColors.grey700,
  );

  late final Future<pw.Font> _regularFont = _loadFont(regularFontAsset);
  late final Future<pw.Font> _boldFont = _loadFont(boldFontAsset);

  static String documentName(GroupReportResponse report) =>
      '${report.groupName} ${report.year}-'
      '${report.month.toString().padLeft(2, '0')}.pdf';

  Future<Uint8List> build(
    GroupReportResponse report, {
    required Translations t,
    String? locale,
  }) async {
    final period = DateFormat.yMMMM(locale)
        .format(DateTime(report.year, report.month));

    final document =
        pw.Document(
          theme: pw.ThemeData.withFont(
            base: await _regularFont,
            bold: await _boldFont,
          ),
          title: '${report.groupName} — $period',
          author: report.groupName,
          subject: period,
        )..addPage(
          pw.MultiPage(
            pageFormat: pageFormat,
            build: (context) => [
              _buildHeading(report, period),
              pw.SizedBox(height: 12),
              _buildTable(t, report),
            ],
          ),
        );

    return document.save();
  }

  Future<pw.Font> _loadFont(String asset) async =>
      pw.Font.ttf(await rootBundle.load(asset));

  pw.Widget _buildHeading(GroupReportResponse report, String period) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(report.groupName, style: _titleStyle),
          pw.SizedBox(height: 2),
          pw.Text(period, style: _subtitleStyle),
        ],
      );

  pw.Widget _buildTable(Translations t, GroupReportResponse report) {
    final dayCount = report.dayCount;
    final lessonDays = report.lessonDays.toSet();
    final dayWidth = _dayWidth(dayCount);

    return pw.Table(
      border: _border,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const pw.FixedColumnWidth(_numberWidth),
        1: const pw.FixedColumnWidth(_nameWidth),
        for (var day = 1; day <= dayCount; day++)
          day + 1: pw.FixedColumnWidth(dayWidth),
        dayCount + 2: const pw.FixedColumnWidth(_paidWidth),
        dayCount + 3: const pw.FixedColumnWidth(_resultWidth),
      },
      children: [
        _buildHeaderRow(t, dayCount),
        for (var index = 0; index < report.students.length; index++)
          _buildStudentRow(report.students[index], index, dayCount, lessonDays),
        _buildTotalRow(t, report),
      ],
    );
  }

  double _dayWidth(int dayCount) {
    final fixedWidth = _numberWidth + _nameWidth + _paidWidth + _resultWidth;

    return math.min(
      _maxDayWidth,
      (pageFormat.availableWidth - fixedWidth) / dayCount,
    );
  }

  pw.TableRow _buildHeaderRow(Translations t, int dayCount) => pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
    children: [
      _buildHeaderCell(t.reports.number),
      _buildHeaderCell(t.reports.fullName, alignment: pw.Alignment.centerLeft),
      for (var day = 1; day <= dayCount; day++) _buildHeaderCell('$day'),
      _buildHeaderCell(t.reports.paid),
      _buildHeaderCell(t.reports.result),
    ],
  );

  pw.TableRow _buildStudentRow(
    GroupReportStudentResponse student,
    int index,
    int dayCount,
    Set<int> lessonDays,
  ) {
    final presentDays = student.presentDays.toSet();

    return pw.TableRow(
      children: [
        _buildCell(pw.Text('${index + 1}', style: _cellStyle)),
        _buildCell(
          pw.Text(student.fullName, style: _cellStyle),
          alignment: pw.Alignment.centerLeft,
        ),
        for (var day = 1; day <= dayCount; day++)
          _buildMarkCell(
            lessonDays.contains(day) ? presentDays.contains(day) : null,
          ),
        _buildMarkCell(student.paid),
        _buildCell(
          pw.Text(
            '${student.presentCount}/${student.lessonCount}',
            style: _cellStyle,
          ),
        ),
      ],
    );
  }

  pw.TableRow _buildTotalRow(Translations t, GroupReportResponse report) =>
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: [
          _buildCell(null),
          _buildCell(null),
          for (var day = 1; day <= report.dayCount; day++) _buildCell(null),
          _buildCell(null),
          _buildCell(
            pw.Text(
              '${report.totalPresent}/${report.totalLessons}',
              style: _totalStyle,
            ),
          ),
        ],
      );

  pw.Widget _buildMarkCell(bool? mark) {
    if (mark == null) return _buildCell(null);

    return _buildCell(_buildMark(mark));
  }

  pw.Widget _buildMark(bool isPresent) => pw.CustomPaint(
    size: const PdfPoint(_markSize, _markSize),
    painter: (canvas, size) {
      canvas
        ..setStrokeColor(isPresent ? _presentColor : _missingColor)
        ..setLineWidth(_markStroke)
        ..setLineCap(PdfLineCap.round)
        ..setLineJoin(PdfLineJoin.round);

      if (isPresent) {
        canvas
          ..moveTo(1.0, 4.6)
          ..lineTo(3.2, 2.0)
          ..lineTo(8.0, 7.4);
      } else {
        canvas
          ..moveTo(1.4, 1.4)
          ..lineTo(7.6, 7.6)
          ..moveTo(7.6, 1.4)
          ..lineTo(1.4, 7.6);
      }

      canvas.strokePath();
    },
  );

  pw.Widget _buildHeaderCell(
    String text, {
    pw.Alignment alignment = pw.Alignment.center,
  }) => _buildCell(pw.Text(text, style: _headerStyle), alignment: alignment);

  pw.Widget _buildCell(
    pw.Widget? child, {
    pw.Alignment alignment = pw.Alignment.center,
  }) => pw.Container(
    alignment: alignment,
    constraints: const pw.BoxConstraints(minHeight: _cellHeight),
    padding: const pw.EdgeInsets.symmetric(horizontal: _cellPadding),
    child: child,
  );
}
