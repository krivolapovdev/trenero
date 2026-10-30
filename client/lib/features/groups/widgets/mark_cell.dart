import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/report_cell.dart';

class MarkCell extends StatelessWidget {
  final List<bool>? marks;

  new({super.key, List<bool>? marks, bool? mark})
    : marks = marks ?? (mark != null ? [mark] : null);

  static Widget _badge(
    BuildContext context,
    bool mark, {
    required double size,
    required double fontSize,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = mark
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));

    final background = mark
        ? (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7))
        : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFEDD5));

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        mark ? '+' : '-',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marks = this.marks;
    if (marks == null || marks.isEmpty) {
      return const ReportCell(child: SizedBox.shrink());
    }

    if (marks.length == 1) {
      return ReportCell(
        child: _badge(context, marks.first, size: 22, fontSize: 14),
      );
    }

    return ReportCell(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
          for (final mark in marks)
            _badge(context, mark, size: 13, fontSize: 9),
        ],
      ),
    );
  }
}
