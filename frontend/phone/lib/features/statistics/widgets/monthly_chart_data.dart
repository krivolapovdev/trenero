import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phone/features/statistics/models/monthly_statistic.dart';
import 'package:phone/features/statistics/widgets/chart_bottom_title.dart';

class MonthlyChartData {
  static const _profitColor = Color(0xFF4CAF50);
  static const _expensesColor = Color(0xFFE00153);
  static const _unselectedOpacity = 0.35;
  static const _barWidth = 12.0;

  static BarChartData build({
    required List<MonthlyStatistic> data,
    required int selectedIndex,
  }) {
    final maxValue = data
        .expand((item) => [item.profit, item.expenses])
        .reduce(math.max);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      minY: 0,
      maxY: maxValue,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barTouchData: const BarTouchData(enabled: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(y: 0, strokeWidth: 1, color: Colors.black),
        ],
      ),
      titlesData: _buildTitles(data, selectedIndex),
      barGroups: _buildBarGroups(data, selectedIndex),
    );
  }

  static FlTitlesData _buildTitles(
    List<MonthlyStatistic> data,
    int selectedIndex,
  ) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }

            return ChartBottomTitle(
              text: data[index].month,
              isSelected: index == selectedIndex,
            );
          },
        ),
      ),
    );
  }

  static List<BarChartGroupData> _buildBarGroups(
    List<MonthlyStatistic> data,
    int selectedIndex,
  ) {
    return List.generate(data.length, (index) {
      final profit = data[index].profit;
      final expenses = data[index].expenses;
      final isSelected = index == selectedIndex;

      final profitColor = isSelected
          ? _profitColor
          : _profitColor.withValues(alpha: _unselectedOpacity);

      final expensesColor = isSelected
          ? _expensesColor
          : _expensesColor.withValues(alpha: _unselectedOpacity);

      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: [
          _buildRod(profit, profitColor),
          _buildRod(expenses, expensesColor),
        ],
      );
    });
  }

  static BarChartRodData _buildRod(double value, Color color) {
    return BarChartRodData(
      toY: value,
      width: _barWidth,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(6),
        topRight: Radius.circular(6),
      ),
      color: color,
    );
  }
}
