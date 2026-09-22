import 'package:flutter/material.dart';
import 'package:phone/features/statistics/models/monthly_statistic.dart';

class SummaryCard extends StatelessWidget {
  final MonthlyStatistic selectedItem;

  const new({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    const expensesColor = Color(0xFFE00153);
    final total = selectedItem.profit - selectedItem.expenses;
    final isPositive = total >= 0;

    final formattedAmount = total
        .abs()
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\.?0+$'), '');

    final displaySign = isPositive ? '+' : '-';
    final displayColor = isPositive ? const Color(0xFF2E7D32) : expensesColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(selectedItem.date, style: const TextStyle(fontSize: 18)),
          Text(
            '$displaySign$formattedAmount',
            style: TextStyle(fontSize: 18, color: displayColor),
          ),
        ],
      ),
    );
  }
}
