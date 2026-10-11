import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const double _labelGap = 12;

class MonthAxisLabel extends StatelessWidget {
  final TitleMeta meta;
  final String? label;

  const new({super.key, required this.meta, this.label});

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    if (label == null) return const SizedBox.shrink();

    return SideTitleWidget(
      meta: meta,
      space: _labelGap,
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }
}
