import 'package:flutter/material.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Attendance grid of a single month: `№ | Full Name | 1..last day | Paid | Result`.
///
/// Every day of the month is a column. A column shows `+` when the student was
/// present, `-` when the student missed the lesson and stays empty when the group
/// had no lesson on that day (`GroupReportResponse.lessonDays`). The last row sums
/// the per student results into a single `present/lessons` cell.
class GroupReportTable extends StatelessWidget {
  static const double _numberWidth = 40;
  static const double _nameWidth = 168;
  static const double _dayWidth = 34;
  static const double _paidWidth = 56;
  static const double _resultWidth = 76;

  static const Color _presentColor = Color(0xFF166534);
  static const Color _presentBackground = Color(0xFFDCFCE7);
  static const Color _absentColor = Color(0xFF9A3412);
  static const Color _absentBackground = Color(0xFFFFEDD5);

  final GroupReportResponse report;

  const new({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayCount = report.dayCount;
    final lessonDays = report.lessonDays.toSet();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.fill,
        border: TableBorder.all(
          color: theme.dividerColor,
          width: 0.5,
          borderRadius: BorderRadius.circular(12),
        ),
        columnWidths: {
          0: const FixedColumnWidth(_numberWidth),
          1: const FixedColumnWidth(_nameWidth),
          for (var day = 1; day <= dayCount; day++)
            day + 1: const FixedColumnWidth(_dayWidth),
          dayCount + 2: const FixedColumnWidth(_paidWidth),
          dayCount + 3: const FixedColumnWidth(_resultWidth),
        },
        children: [
          _buildHeaderRow(context, dayCount),
          for (var index = 0; index < report.students.length; index++)
            _buildStudentRow(
              context,
              report.students[index],
              index,
              dayCount,
              lessonDays,
            ),
          _buildTotalRow(context, dayCount),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow(BuildContext context, int dayCount) => TableRow(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
    children: [
      _buildCell(_buildHeaderText(context, context.t.reports.number)),
      _buildCell(
        _buildHeaderText(context, context.t.reports.fullName),
        alignment: Alignment.centerLeft,
      ),
      for (var day = 1; day <= dayCount; day++)
        _buildCell(_buildHeaderText(context, '$day')),
      _buildCell(_buildHeaderText(context, context.t.reports.paid)),
      _buildCell(_buildHeaderText(context, context.t.reports.result)),
    ],
  );

  TableRow _buildStudentRow(
    BuildContext context,
    GroupReportStudentResponse student,
    int index,
    int dayCount,
    Set<int> lessonDays,
  ) {
    final presentDays = student.presentDays.toSet();

    return TableRow(
      children: [
        _buildCell(_buildBodyText(context, '${index + 1}')),
        _buildCell(
          _buildBodyText(context, student.fullName, maxLines: 1),
          alignment: Alignment.centerLeft,
        ),
        for (var day = 1; day <= dayCount; day++)
          _buildMarkCell(
            context,
            lessonDays.contains(day) ? presentDays.contains(day) : null,
          ),
        _buildMarkCell(context, student.paid),
        _buildCell(
          _buildBodyText(
            context,
            '${student.presentCount}/${student.lessonCount}',
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  TableRow _buildTotalRow(BuildContext context, int dayCount) => TableRow(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
    children: [
      _buildCell(const SizedBox.shrink()),
      _buildCell(
        _buildBodyText(
          context,
          context.t.reports.total,
          weight: FontWeight.w700,
        ),
        alignment: Alignment.centerLeft,
      ),
      for (var day = 1; day <= dayCount; day++)
        _buildCell(const SizedBox.shrink()),
      _buildCell(const SizedBox.shrink()),
      _buildCell(
        _buildBodyText(
          context,
          '${report.totalPresent}/${report.totalLessons}',
          weight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _buildMarkCell(BuildContext context, bool? mark) => _buildCell(
    _buildMark(mark),
    backgroundColor: mark == null
        ? null
        : (mark ? _presentBackground : _absentBackground),
  );

  Widget _buildMark(bool? mark) {
    if (mark == null) return const SizedBox.shrink();

    return Text(
      mark ? '+' : '-',
      style: TextStyle(
        color: mark ? _presentColor : _absentColor,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }

  Widget _buildCell(
    Widget child, {
    Alignment alignment = Alignment.center,
    Color? backgroundColor,
  }) => Container(
    alignment: alignment,
    color: backgroundColor,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    child: child,
  );

  Widget _buildHeaderText(BuildContext context, String text) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.labelMedium
        ?.copyWith(fontWeight: FontWeight.w700),
  );

  Widget _buildBodyText(
    BuildContext context,
    String text, {
    FontWeight? weight,
    int? maxLines,
  }) => Text(
    text,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: weight),
  );
}
