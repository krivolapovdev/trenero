import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RecentTransactionsHeader extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onSeeAllPressed;

  const new({super.key, required this.isLoading, this.onSeeAllPressed});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    child: Skeletonizer(
      enabled: isLoading,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.t.finance.lastTransactions,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          if (onSeeAllPressed != null)
            TextButton(
              onPressed: onSeeAllPressed,
              child: Text(context.t.all, style: const TextStyle(fontSize: 16)),
            ),
        ],
      ),
    ),
  );
}
