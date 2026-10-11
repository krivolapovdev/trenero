import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_lottie.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/i18n/strings.g.dart';

class ErrorNotice extends StatelessWidget {
  static const double _contentPadding = AppSpacing.xxl;

  final VoidCallback? onRepeat;

  const new({super.key, required this.onRepeat});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(_contentPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: Lottie.asset(AppLottie.error),
          ),

          Text(
            context.t.pleaseUpdateApp,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: AppSpacing.lg),

          TextButton(onPressed: onRepeat, child: Text(context.t.repeat)),
        ],
      ),
    ),
  );
}
