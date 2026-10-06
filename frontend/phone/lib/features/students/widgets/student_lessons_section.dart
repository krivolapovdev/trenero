import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/features/students/controllers/student_lessons_controller.dart';
import 'package:phone/generated/models/visit_type.dart';

class StudentLessonsSection extends ConsumerWidget {
  final String studentId;

  const new({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(studentLessonsProvider(studentId));
    final localeAsync = ref.watch(languageProvider);

    return visitsAsync.when(
      data: (visitsWithLessons) {
        final lessons = visitsWithLessons
            .where(
              (v) =>
                  v.visit.type == VisitType.regular ||
                  v.visit.type == VisitType.free,
            )
            .map((v) => v.lesson)
            .toList();

        return LessonsCalendar(
          lessons: lessons,
          locale: localeAsync.value?.languageTag,
          onDaySelected: (selectedDay, focusedDay) {
            // Handle day tap if needed
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading lessons: $error')),
    );
  }
}
