import 'package:flutter/material.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/features/students/extensions/student_status_extension.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentCard extends StatelessWidget {
  final StudentSummaryResponse student;
  final VoidCallback onTap;

  const new({super.key, required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasNote = student.note != null && student.note!.trim().isNotEmpty;
    final hasPhone = student.phone != null && student.phone!.isNotEmpty;
    final groupLabel = _groupLabel(student);
    final hasGroup = groupLabel.isNotEmpty;
    final badges = student.statuses.toBadges(context);

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
                    backgroundColor: student.id.toColor(),
                    child: Text(
                      student.fullName.initials,
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
                          student.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),

                        if (hasGroup) ...[
                          const SizedBox(height: 2),
                          Text(
                            groupLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        if (hasPhone) ...[
                          const SizedBox(height: 2),
                          Text(
                            student.phone!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: badges
                              .map(
                                (badge) => CardBadge(
                                  icon: badge.icon,
                                  label: badge.label,
                                  backgroundColor: badge.backgroundColor,
                                  foregroundColor: badge.foregroundColor,
                                ),
                              )
                              .toList(),
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
                  student.note!,
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

  /// Every group of the student joined into a label, each group carrying its
  /// default price when it has one.
  ///
  /// The summary carries the full list of groups the student belongs to; the
  /// single group is the fallback for a response that only holds the primary
  /// one.
  static String _groupLabel(StudentSummaryResponse student) {
    final groups = student.studentGroups;
    final labels = <String>[];

    if (groups != null) {
      for (final group in groups) {
        if (group.name.trim().isEmpty) continue;
        labels.add(_labelOf(group.name, group.defaultPrice));
      }
    }

    if (labels.isEmpty) {
      final group = student.studentGroup;

      if (group != null && group.name.trim().isNotEmpty) {
        labels.add(_labelOf(group.name, group.defaultPrice));
      }
    }

    return labels.join(', ');
  }

  static String _labelOf(String name, num? defaultPrice) =>
      defaultPrice != null ? '$name · $defaultPrice' : name;
}
