import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';

class SheetAction extends StatelessWidget {
  static const double _height = 50;
  static const double _cornerRadius = AppRadius.md;

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDestructive;

  const new({
    super.key,
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
