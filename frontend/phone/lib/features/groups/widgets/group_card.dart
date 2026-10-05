import 'package:flutter/material.dart';
import 'package:phone/core/extensions/number_extension.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/generated/models/group_summary_response.dart';

class GroupCard extends StatelessWidget {
  final GroupSummaryResponse group;
  final VoidCallback onTap;

  const new({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasNote = group.note != null && group.note!.trim().isNotEmpty;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: group.id.toColor(),
                    child: Text(
                      group.name.initials,
                      style: TextStyle(
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
                          group.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            CardBadge(
                              icon: const Icon(Icons.people_alt_outlined),
                              label: '${group.groupStudents.length}',
                              backgroundColor: colorScheme.primaryContainer
                                  .withValues(alpha: 0.6),
                              foregroundColor: colorScheme.onPrimaryContainer,
                            ),

                            const SizedBox(width: 8),

                            if (group.defaultPrice != null)
                              CardBadge(
                                icon: const Icon(Icons.sell_outlined),
                                label: group.defaultPrice!.toFormattedAmount(
                                  showSign: false,
                                ),
                                backgroundColor: const Color(0xFFE8F5E9)
                                    .withValues(alpha: 0.6),
                                foregroundColor: const Color(0xFF2E7D32),
                              ),
                          ],
                        ),
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
                  group.note!,
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
