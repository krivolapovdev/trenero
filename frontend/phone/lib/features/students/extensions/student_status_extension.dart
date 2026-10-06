import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phone/features/students/models/student_badge_data.dart';
import 'package:phone/generated/models/student_status.dart';
import 'package:phone/i18n/strings.g.dart';

extension StudentStatusExtension on List<StudentStatus> {
  List<StudentBadgeData> toBadges(BuildContext context) {
    final t = context.t;
    final colorScheme = Theme.of(context).colorScheme;

    return map(
      (status) => switch (status) {
        StudentStatus.inactive => StudentBadgeData(
          id: status.name,
          icon: const Icon(Icons.question_mark_rounded),
          label: t.students.status.inactive,
          backgroundColor: const Color(0xFFF1F5F9),
          foregroundColor: const Color(0xFF64748B),
        ),

        StudentStatus.present => StudentBadgeData(
          id: status.name,
          icon: const Icon(CupertinoIcons.checkmark),
          label: t.students.status.present,
          backgroundColor: const Color(0xFFDCFCE7),
          foregroundColor: const Color(0xFF166534),
        ),

        StudentStatus.missing => StudentBadgeData(
          id: status.name,
          icon: const Icon(CupertinoIcons.xmark),
          label: t.students.status.missing,
          backgroundColor: const Color(0xFFFFEDD5).withValues(alpha: 0.8),
          foregroundColor: const Color(0xFF9A3412),
        ),

        StudentStatus.paid => StudentBadgeData(
          id: status.name,
          icon: const Icon(CupertinoIcons.plus),
          label: t.students.status.paid,
          backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
          foregroundColor: colorScheme.primary,
        ),

        StudentStatus.unpaid => StudentBadgeData(
          id: status.name,
          icon: const Icon(CupertinoIcons.minus),
          label: t.students.status.unpaid,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        ),

        StudentStatus.$unknown => StudentBadgeData(
          id: status.name,
          label: '',
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
        ),
      },
    ).toList();
  }
}
