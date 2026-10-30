import 'package:flutter/material.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/core/widgets/date_input_field.dart';
import 'package:phone/features/students/extensions/student_status_extension.dart';
import 'package:phone/features/students/widgets/student_badges.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentCard extends StatelessWidget {
  final StudentSummaryResponse student;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  final String? overrideInitials;
  final bool showBirthdate;
  final bool noteVisible;
  final bool groupsVisible;
  final BorderRadius? borderRadius;

  const new({
    super.key,
    required this.student,
    required this.onTap,
    this.onLongPress,
    this.overrideInitials,
    this.showBirthdate = false,
    this.noteVisible = true,
    this.groupsVisible = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasNote =
        noteVisible && student.note != null && student.note!.trim().isNotEmpty;
    final hasPhone = student.phone != null && student.phone!.isNotEmpty;
    final birthdate = student.birthdate;
    final groupLabels = _groupLabels(student);
    final hasGroup = groupsVisible && groupLabels.isNotEmpty;
    final badges = student.statuses.toBadges(context);
    final cardRadius = borderRadius ?? BorderRadius.circular(16);

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
                    backgroundColor: student.id.toColor(),
                    child: Text(
                      overrideInitials ?? student.fullName.initials,
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final groupLabel in groupLabels)
                                Text(
                                  groupLabel,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],

                        if (showBirthdate && birthdate != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            DateInputField.format(birthdate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        if (hasPhone) ...[
                          const SizedBox(height: 2),
                          Text(
                            student.phone!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        StudentBadges(badges: badges),
                      ],
                    ),
                  ),
                ],
              ),

              if (hasNote) ...<Widget>[
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

  static List<String> _groupLabels(StudentSummaryResponse student) {
    final groups = student.studentGroups;
    final labels = <String>[];

    if (groups != null) {
      for (final group in groups) {
        if (group.name.trim().isEmpty) continue;
        labels.add(group.name);
      }
    }

    return labels;
  }
}
