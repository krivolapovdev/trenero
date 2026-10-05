import 'package:flutter/material.dart';

class GroupPopupMenu extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: '',
    offset: const Offset(-8, 0),
    color: Theme.of(context).colorScheme.surface,
    itemBuilder: (BuildContext context) => [
      PopupMenuItem<String>(
        onTap: () {},
        child: const Row(
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 12),
            Text('Edit'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () {},
        child: const Row(
          children: [
            Icon(Icons.calendar_month, size: 20),
            SizedBox(width: 12),
            Text('Lesson'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () {},
        child: const Row(
          children: [
            Icon(Icons.inventory, size: 20),
            SizedBox(width: 12),
            Text('Archive'),
          ],
        ),
      ),
      PopupMenuItem<String>(
        onTap: () {},
        child: Row(
          children: [
            Icon(
              Icons.delete,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    ],
  );
}
