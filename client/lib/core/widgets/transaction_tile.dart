import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/features/finance/models/transaction_tile_info.dart';
import 'package:phone/generated/models/transaction_response.dart';
import 'package:phone/generated/models/transaction_type.dart';

class TransactionTile extends StatelessWidget {
  final TransactionResponse transaction;
  final String? overrideTitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final EdgeInsetsGeometry contentPadding;

  final BorderRadius borderRadius;

  const new({
    super.key,
    required this.transaction,
    this.overrideTitle,
    this.onTap,
    this.onLongPress,
    this.contentPadding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount =
        (transaction.type == TransactionType.income
                ? transaction.amount
                : -transaction.amount)
            .toFormattedAmount();
    final info = TransactionTileInfo.fromTransaction(
      transaction,
      overrideTitle: overrideTitle,
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius,
        child: Padding(
          padding: contentPadding.add(
            const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: info.backgroundColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(info.icon, color: info.backgroundColor, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Text(
                      info.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Text(
                formattedAmount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: transaction.type == TransactionType.income
                      ? AppColors.income
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
