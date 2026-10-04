import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/extensions/number_extensions.dart';
import 'package:phone/generated/models/payment_metric_response.dart';

class SummaryCard extends StatelessWidget {
  final PaymentMetricResponse selectedItem;

  const new({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    const expensesColor = Color(0xFFE00153);
    const incomeColor = Color(0xFF2E7D32);

    final total = selectedItem.total ?? 0;
    final isPositive = total >= 0;
    final displayColor = isPositive ? incomeColor : expensesColor;
    final formattedDate = selectedItem.date != null
        ? DateFormat('MM/yyyy').format(selectedItem.date!)
        : '---';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(formattedDate, style: const TextStyle(fontSize: 18)),
          Text(
            total.toFormattedAmount(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }
}
