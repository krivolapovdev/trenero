import 'package:flutter/material.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

/// Attendance grid of a single month: `№ | Full Name | 1..last day | Paid | Result`.
class GroupReportTable extends StatelessWidget {
  static const double _numberWidth = 38;
  static const double _nameWidth = 170;
  static const double _dayWidth = 36;
  static const double _paidWidth = 52;
  static const double _resultWidth = 72;

  final GroupReportResponse report;
  final Color? headerBackgroundColor;
  final Color? bottomBackgroundColor;

  const new({
    super.key,
    required this.report,
    this.headerBackgroundColor,
    this.bottomBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayCount = report.dayCount;
    final lessonDays = report.lessonDays.toSet();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            verticalInside: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
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
      ),
    );
  }

  TableRow _buildHeaderRow(BuildContext context, int dayCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TableRow(
      decoration: BoxDecoration(
        // Set top row background color here
        color: headerBackgroundColor ?? colorScheme.surfaceContainerHighest,
      ),
      children: [
        _buildHeaderCell(context, context.t.reports.number),
        _buildHeaderCell(
          context,
          context.t.reports.fullName,
          alignment: Alignment.centerLeft,
        ),
        for (var day = 1; day <= dayCount; day++)
          _buildHeaderCell(context, '$day'),
        _buildHeaderCell(context, context.t.reports.paid),
        _buildHeaderCell(context, context.t.reports.result),
      ],
    );
  }

  TableRow _buildStudentRow(
    BuildContext context,
    GroupReportStudentResponse student,
    int index,
    int dayCount,
    Set<int> lessonDays,
  ) {
    final theme = Theme.of(context);
    final presentDays = student.presentDays.toSet();
    final isEven = index.isEven;

    final rowBackground = isEven
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerLowest;

    return TableRow(
      decoration: BoxDecoration(color: rowBackground),
      children: [
        _buildCell(
          Text(
            '${index + 1}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _buildCell(
          Text(
            student.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          alignment: Alignment.centerLeft,
        ),
        for (var day = 1; day <= dayCount; day++)
          _buildMarkCell(
            context,
            lessonDays.contains(day) ? presentDays.contains(day) : null,
          ),
        _buildMarkCell(context, student.paid),
        _buildCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${student.presentCount}/${student.lessonCount}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTotalRow(BuildContext context, int dayCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TableRow(
      decoration: BoxDecoration(
        // Set bottom row background color here
        color: bottomBackgroundColor ?? colorScheme.surfaceContainerHighest,
      ),
      children: [
        _buildCell(const SizedBox.shrink()),
        _buildCell(const SizedBox.shrink()),
        for (var day = 1; day <= dayCount; day++)
          _buildCell(const SizedBox.shrink()),
        _buildCell(const SizedBox.shrink()),
        _buildCell(
          Text(
            '${report.totalPresent}/${report.totalLessons}',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkCell(BuildContext context, bool? mark) {
    if (mark == null) return _buildCell(const SizedBox.shrink());

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = mark
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));

    final background = mark
        ? (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7))
        : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFEDD5));

    return _buildCell(
      Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(
          mark ? Icons.check_rounded : Icons.close_rounded,
          size: 14,
          color: color,
        ),
      ),
    );
  }

  Widget _buildHeaderCell(
    BuildContext context,
    String text, {
    Alignment alignment = Alignment.center,
  }) {
    final theme = Theme.of(context);
    return _buildCell(
      Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
      ),
      alignment: alignment,
    );
  }

  Widget _buildCell(Widget child, {Alignment alignment = Alignment.center}) =>
      Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: child,
      );
}
