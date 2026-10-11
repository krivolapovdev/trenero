import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/scrollable_fit.dart';
import 'package:phone/i18n/strings.g.dart';

/// A centred message with a single recovery action.
///
/// Reuse it for the empty, error and filter states of a screen instead of
/// rebuilding the same column of widgets in every page.
class RetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? actionLabel;
  final Color? messageColor;
  final bool scrollable;

  const new({
    super.key,
    required this.message,
    required this.onRetry,
    this.actionLabel,
    this.messageColor,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: messageColor == null ? null : TextStyle(color: messageColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onRetry,
            child: Text(actionLabel ?? context.t.repeat),
          ),
        ],
      ),
    );

    return scrollable ? ScrollableFit(child: content) : content;
  }
}
