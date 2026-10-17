import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_lottie.dart';
import 'package:phone/core/constants/app_spacing.dart';

class EmptyState extends StatelessWidget {
  static const double defaultLottieHeight = 220;

  final String buttonText;
  final String subtitle;
  final String lottieAsset;
  final double lottieHeight;
  final VoidCallback onButtonPressed;

  const new({
    super.key,
    required this.buttonText,
    required this.subtitle,
    required this.onButtonPressed,
    this.lottieAsset = AppLottie.emptyBox,
    this.lottieHeight = defaultLottieHeight,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: lottieHeight,
          child: Lottie.asset(lottieAsset, fit: BoxFit.contain),
        ),

        FilledButton.icon(
          icon: const Icon(Icons.add_circle_rounded),
          onPressed: onButtonPressed,
          label: Text(buttonText, style: const TextStyle(fontSize: 14)),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(subtitle),
      ],
    ),
  );
}
