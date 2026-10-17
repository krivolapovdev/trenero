import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentAppMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onCreatePayment;
  final VoidCallback onAssignGroup;
  final VoidCallback onReport;
  final VoidCallback onDelete;

  const new({
    super.key,
    required this.onEdit,
    required this.onCreatePayment,
    required this.onAssignGroup,
    required this.onReport,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(-8, 0),
      color: Theme.of(context).colorScheme.surface,
      itemBuilder: (menuContext) => [
        PopupMenuItem<String>(
          onTap: onEdit,
          child: Row(
            children: [
              const Icon(CupertinoIcons.text_cursor, size: 20),
              const SizedBox(width: 12),
              Text(context.t.edit),
            ],
          ),
        ),

        PopupMenuItem<String>(
          onTap: onAssignGroup,
          child: Row(
            children: [
              const Icon(CupertinoIcons.person_2_square_stack, size: 20),
              const SizedBox(width: 12),
              Text(context.t.groups.title),
            ],
          ),
        ),

        PopupMenuItem<String>(
          onTap: onReport,
          child: Row(
            children: [
              const Icon(CupertinoIcons.printer, size: 20),
              const SizedBox(width: 12),
              Text(context.t.groups.report),
            ],
          ),
        ),

        PopupMenuItem<String>(
          onTap: onCreatePayment,
          child: Row(
            children: [
              const Icon(FluentIcons.money_24_regular, size: 20),
              const SizedBox(width: 12),
              Text(context.t.students.payment),
            ],
          ),
        ),

        PopupMenuItem<String>(
          onTap: onDelete,
          child: Row(
            children: [
              Icon(CupertinoIcons.trash, size: 20, color: errorColor),
              const SizedBox(width: 12),
              Text(context.t.delete, style: TextStyle(color: errorColor)),
            ],
          ),
        ),
      ],
    );
  }
}
