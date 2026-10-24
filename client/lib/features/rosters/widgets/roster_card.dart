import 'package:flutter/material.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/generated/models/roster_response.dart';

class RosterCard extends StatelessWidget {
  final RosterResponse roster;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool noteVisible;
  final BorderRadius? borderRadius;

  const new({
    super.key,
    required this.roster,
    required this.onTap,
    this.onLongPress,
    this.noteVisible = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasNote =
        noteVisible && roster.note != null && roster.note!.trim().isNotEmpty;
    final cardRadius = borderRadius ?? BorderRadius.circular(16);
    final count = roster.countOfStudents ?? roster.students?.length ?? 0;
    final hasDate = roster.date != null;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: cardRadius),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: roster.id.toColor(),
                    child: Text(
                      roster.name.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${roster.name}: $count',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                        if (hasDate) ...[
                          const SizedBox(height: 2),
                          Text(
                            DateInputField.format(roster.date!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (hasNote) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 12),
                Text(
                  roster.note!,
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
