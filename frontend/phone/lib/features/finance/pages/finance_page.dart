import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/shell_page.dart';
import 'package:phone/features/finance/data/monthly_data.dart';
import 'package:phone/features/finance/widgets/create_transaction_bottom_sheet.dart';
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
  List<Widget> actions(BuildContext context) => [
    IconButton(
      icon: const Icon(FluentIcons.savings_24_regular),
      onPressed: () => AppBottomSheet.show(
        context: context,
        child: const CreateTransactionBottomSheet(),
      ),
    ),

    SizedBox(width: 8),
  ];

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
