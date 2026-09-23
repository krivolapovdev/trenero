import 'package:flutter/material.dart';
import 'package:phone/core/widgets/titled_page.dart';
import 'package:phone/features/statistics/data/monthly_data.dart';
import 'package:phone/features/statistics/widgets/monthly_bar_chart.dart';
import 'package:phone/features/statistics/widgets/summary_card.dart';

class StatisticsPage extends TitledPage {
  const new({
    super.key,
    required super.title,
    super.icon = Icons.insert_chart_outlined_outlined,
    super.selectedIcon = Icons.insert_chart,
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
              children: [
                SummaryCard(selectedItem: monthlyData[selectedIndex]),

                const SizedBox(height: 16),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
