import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/report_cell.dart';

class MarkCell extends StatelessWidget {
  final bool? mark;

  const new({super.key, required this.mark});

  @override
  Widget build(BuildContext context) {
    final mark = this.mark;
    if (mark == null) return const ReportCell(child: SizedBox.shrink());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = mark
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));

    final background = mark
        ? (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7))
        : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFEDD5));

    return ReportCell(
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Text(
          mark ? '+' : '-',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
