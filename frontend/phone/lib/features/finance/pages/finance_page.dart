import 'package:flutter/material.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/finance/data/monthly_data.dart';
import 'package:phone/features/finance/widgets/action_card.dart';
import 'package:phone/features/finance/widgets/monthly_bar_chart.dart';
import 'package:phone/features/finance/widgets/summary_card.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FinancePage extends ShellPage {
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

                ActionCard(
                  title: context.t.reports.title,
                  subtitle: context.t.reports.subtitle,
                  icon: FaIcon(FontAwesomeIcons.chartLine),
                  onTap: () {},
                ),

                ActionCard(
                  title: context.t.transactions.title,
                  subtitle: context.t.transactions.subtitle,
                  icon: FaIcon(FontAwesomeIcons.dollarSign),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
