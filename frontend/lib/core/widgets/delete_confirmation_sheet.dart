import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/i18n/strings.g.dart';

class DeleteConfirmationSheet extends StatefulWidget {
  final String title;

  final String message;

  final Future<String?> Function() delete;

  const new({
    super.key,
    required this.title,
    required this.message,
    required this.delete,
  });

  @override
  State<DeleteConfirmationSheet> createState() =>
      _DeleteConfirmationSheetState();
}

class _DeleteConfirmationSheetState extends State<DeleteConfirmationSheet> {
  bool _isLoading = false;

  Future<void> _onDelete() async {
    setState(() {
      _isLoading = true;
    });

    final error = await widget.delete();

    if (!mounted) return;

    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isLoading = false;
    });

    AppSnackBar.show(context, error, SnackBarType.error);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            widget.message,
            style: const TextStyle(fontSize: 16, color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          _SheetAction(
            label: context.t.delete,
            onPressed: _onDelete,
            isLoading: _isLoading,
            isDestructive: true,
          ),

          const SizedBox(height: AppSpacing.sm),

          _SheetAction(
            label: context.t.cancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

class _SheetAction extends StatelessWidget {
  static const double _height = 50;
  static const double _cornerRadius = AppRadius.md;

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDestructive;

  const new({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: _height,
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isDestructive ? Colors.red.shade50 : null,
        foregroundColor: isDestructive ? Colors.red : Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label, style: const TextStyle(fontSize: 16)),
    ),
  );
}
