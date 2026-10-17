import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class IndividualLessonMenu extends StatelessWidget {
  final VoidCallback onDelete;

  const new({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(-8, 0),
      color: colorScheme.surface,
      itemBuilder: (menuContext) => [
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
