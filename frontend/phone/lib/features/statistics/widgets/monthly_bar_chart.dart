import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phone/features/statistics/data/monthly_statistic.dart';
import 'package:phone/features/statistics/widgets/chart_touch_overlay.dart';
import 'package:phone/features/statistics/widgets/monthly_chart_data.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyStatistic> data;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const new({
    super.key,
    required this.data,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          BarChart(
            MonthlyChartData.build(data: data, selectedIndex: selectedIndex),
          ),

          ChartTouchOverlay(
            itemCount: data.length,
            onIndexChanged: onIndexChanged,
          ),
        ],
      ),
    );
  }
}
