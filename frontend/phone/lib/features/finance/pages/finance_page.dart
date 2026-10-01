// lib/features/finance/pages/finance_page.dart
import 'package:flutter/material.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/finance/data/monthly_data.dart';
import 'package:phone/features/finance/widgets/monthly_bar_chart.dart';
import 'package:phone/features/finance/widgets/recent_transactions.dart';
import 'package:phone/features/finance/widgets/summary_card.dart';

class FinancePage extends ShellPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.monetization_on_outlined,
    super.selectedIcon = Icons.monetization_on,
  });

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 5;

    return StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
              children: [
                SummaryCard(selectedItem: monthlyData[selectedIndex]),

                MonthlyBarChart(
                  data: monthlyData,
                  selectedIndex: selectedIndex,
                  onIndexChanged: (index) {
                    if (selectedIndex != index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    }
                  },
                ),

                RecentTransactions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
