import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_lottie.dart';

class EmptyState extends StatelessWidget {
  final String buttonText;
  final String subtitle;
  final IconData buttonIcon;
  final String lottieAsset;
  final double lottieHeight;
  final VoidCallback onButtonPressed;

  const new({
    super.key,
    required this.buttonText,
    required this.subtitle,
    required this.onButtonPressed,
    this.lottieAsset = AppLottie.emptyBox,
    this.buttonIcon = Icons.add_circle_rounded,
    this.lottieHeight = 220,
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
          label: Text(buttonText, style: TextStyle(fontSize: 14)),
        ),

        const SizedBox(height: 8),

        Text(subtitle),
      ],
    ),
  );
}
