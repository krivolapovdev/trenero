import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phone/core/constants/app_lottie.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/i18n/strings.g.dart';

class GlobalErrorPage extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRepeat;

  const new({super.key, this.error, this.onRepeat});

  @override
  Widget build(BuildContext context) {
    final error = this.error;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _ErrorNotice(onRepeat: onRepeat)),
            if (error != null) _ErrorDetails(error: error),
          ],
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  static const double _contentPadding = AppSpacing.xxl;

  final VoidCallback? onRepeat;

  const new({required this.onRepeat});

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

class _ErrorDetails extends StatelessWidget {
  static const double _contentPadding = AppSpacing.xxl;

  final Object error;

  const new({required this.error});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      _contentPadding,
      AppSpacing.sm,
      _contentPadding,
      _contentPadding,
    ),
    child: Text(
      '$error',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
