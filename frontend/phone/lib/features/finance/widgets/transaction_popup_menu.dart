import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

/// Dropdown menu with the actions available for a single transaction.
class TransactionPopupMenu extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const new({super.key, required this.onUpdate, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(-8, 0),
      color: colorScheme.surface,
      itemBuilder: (menuContext) => [
        PopupMenuItem<String>(
          onTap: onUpdate,
          child: Row(
            children: [
              const Icon(Icons.edit, size: 20),
              const SizedBox(width: 12),
              Text(context.t.update),
            ],
          ),
        ),
        PopupMenuItem<String>(
          onTap: onDelete,
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: colorScheme.error),
              const SizedBox(width: 12),
              Text(
                context.t.delete,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
