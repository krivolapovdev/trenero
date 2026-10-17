import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/header_cell.dart';
import 'package:phone/features/groups/widgets/mark_cell.dart';
import 'package:phone/features/groups/widgets/report_cell.dart';
import 'package:phone/generated/models/group_report_response.dart';
import 'package:phone/generated/models/group_report_student_response.dart';
import 'package:phone/i18n/strings.g.dart';

const double _numberWidth = 38;
const double _nameWidth = 170;
const double _dayWidth = 36;
const double _paidWidth = 52;
const double _resultWidth = 72;

TableRow _headerRow(BuildContext context, int dayCount) {
  final colorScheme = Theme.of(context).colorScheme;

  return TableRow(
    decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
    children: [
      HeaderCell(text: context.t.reports.number),
      HeaderCell(
        text: context.t.reports.fullName,
        alignment: Alignment.centerLeft,
      ),
      for (var day = 1; day <= dayCount; day++) HeaderCell(text: '$day'),
      HeaderCell(text: context.t.reports.paid),
      HeaderCell(text: context.t.reports.result),
    ],
  );
}

TableRow _studentRow(
  BuildContext context,
  GroupReportStudentResponse student,
  int index,
  int dayCount,
  Set<int> lessonDays,
) {
  final theme = Theme.of(context);
  final presentDays = student.presentDays.toSet();

  final rowBackground = index.isEven
      ? theme.colorScheme.surface
      : theme.colorScheme.surfaceContainerLowest;

  return TableRow(
    decoration: BoxDecoration(color: rowBackground),
    children: [
      ReportCell(
        child: Text(
          '${index + 1}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      ReportCell(
        alignment: Alignment.centerLeft,
        child: Text(
          student.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      for (var day = 1; day <= dayCount; day++)
        MarkCell(
          mark: lessonDays.contains(day) ? presentDays.contains(day) : null,
        ),
      MarkCell(mark: student.paid),
      ReportCell(
        child: Container(
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

TableRow _totalRow(BuildContext context, GroupReportResponse report) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final dayCount = report.dayCount;

  return TableRow(
    decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
    children: [
      ReportCell(
        alignment: Alignment.centerLeft,
        child: Text(
          context.t.reports.total,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const ReportCell(child: SizedBox.shrink()),
      for (var day = 1; day <= dayCount; day++)
        const ReportCell(child: SizedBox.shrink()),
      const ReportCell(child: SizedBox.shrink()),
      ReportCell(
        child: Text(
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

class GroupReportTable extends StatelessWidget {
  final GroupReportResponse report;

  const new({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayCount = report.dayCount;
    final lessonDays = report.lessonDays.toSet();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            verticalInside: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
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
            _headerRow(context, dayCount),
            for (var index = 0; index < report.students.length; index++)
              _studentRow(
                context,
                report.students[index],
                index,
                dayCount,
                lessonDays,
              ),
            _totalRow(context, report),
          ],
        ),
      ),
    );
  }
}
