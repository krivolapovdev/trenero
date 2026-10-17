import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';

class TicketDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const new({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedText,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        value,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    ],
  );
}
