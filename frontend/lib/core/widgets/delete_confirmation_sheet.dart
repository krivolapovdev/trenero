import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/widgets/app_snack_bar.dart';
import 'package:phone/core/widgets/sheet_action.dart';
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

          SheetAction(
            label: context.t.delete,
            onPressed: _onDelete,
            isLoading: _isLoading,
            isDestructive: true,
          ),

          const SizedBox(height: AppSpacing.sm),

          SheetAction(
            label: context.t.cancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

