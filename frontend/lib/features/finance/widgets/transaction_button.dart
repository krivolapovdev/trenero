import 'package:flutter/material.dart';

class TransactionButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onPressed;

  const new({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => FilledButton(
    style: FilledButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
    onPressed: onPressed,
    child: Row(
      children: [
        const SizedBox(width: 8),
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16.0),
            // textAlign: TextAlign.center,
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.black54, size: 20.0),
      ],
    ),
  );
}
