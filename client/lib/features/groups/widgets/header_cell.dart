import 'package:flutter/material.dart';
import 'package:phone/features/groups/widgets/report_cell.dart';

class HeaderCell extends StatelessWidget {
  final String text;
  final Alignment alignment;

  const new({super.key, required this.text, this.alignment = Alignment.center});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ReportCell(
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
