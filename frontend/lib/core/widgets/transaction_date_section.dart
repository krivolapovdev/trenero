import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/transaction_tile.dart';
import 'package:phone/features/finance/pages/transaction_page.dart';
import 'package:phone/generated/models/transaction_response.dart';

class TransactionDateSection extends StatelessWidget {
  final String dateHeader;
  final List<TransactionResponse> transactions;
  final String? overrideTitle;
  final bool isLoading;

  const new({
    super.key,
    required this.dateHeader,
    required this.transactions,
    required this.isLoading,
    this.overrideTitle,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(
          top: AppSpacing.xl,
          bottom: AppSpacing.sm,
        ),
        child: Text(
          dateHeader,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            for (final transaction in transactions)
              TransactionTile(
                key: ValueKey(transaction.id),
                transaction: transaction,
                overrideTitle: overrideTitle,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                borderRadius: BorderRadius.zero,
                onTap: isLoading
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TransactionPage(
                            transaction: transaction,
                            overrideTitle: overrideTitle,
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    ],
  );
}
