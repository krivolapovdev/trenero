import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/generated/models/roster_response.dart';
import 'package:phone/i18n/strings.g.dart';

class RosterTile extends StatelessWidget {
  final RosterResponse roster;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool enabled;

  const new({
    super.key,
    required this.roster,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final count = roster.countOfStudents ?? roster.students?.length ?? 0;
    final hasNote = roster.note != null && roster.note!.trim().isNotEmpty;
    final subtitle = hasNote
        ? roster.note!
        : context.t.rosters.studentsCount(count: count);

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled && onEdit != null ? onEdit : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Square thumbnail with rounded corners matching the image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: roster.id.toColor(),
                  alignment: Alignment.center,
                  child: roster.name.initials.isNotEmpty
                      ? Text(
                          roster.name.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : const Icon(
                          Icons.format_list_bulleted,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            roster.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFD1D1D6),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing 3-dots button matching the image
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  enabled: enabled,
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Color(0xFF8E8E93),
                    size: 24,
                  ),
                  tooltip: '',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.pencil, size: 20),
                            const SizedBox(width: 12),
                            Text(context.t.edit),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.trash,
                              size: 20,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.t.delete,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                )
              else
                const Icon(
                  Icons.more_horiz,
                  color: Color(0xFF8E8E93),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
