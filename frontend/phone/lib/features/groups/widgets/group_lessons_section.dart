import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupLessonsSection extends ConsumerWidget {
  final String groupId;

  const new({super.key, required this.groupId});

  static final List<LessonResponse> _dummyLessons = List.generate(6, (index) {
    final date = DateTime.now().add(Duration(days: index * 3));
    return LessonResponse(
      id: 'placeholder-$index',
      date: date,
      createdAt: date,
    );
  });

  /// Opens the lesson of the tapped day, or an empty page when the day has no
  /// lesson yet.
  Future<void> _openLessonPage(
    BuildContext context,
    DateTime selectedDay,
    List<LessonResponse> dayLessons,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonPage(
          groupId: groupId,
          date: selectedDay,
          lesson: dayLessons.firstOrNull,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(groupLessonsProvider(groupId));
    final localeAsync = ref.watch(languageProvider);

    return lessonsAsync.when(
      data: (lessons) => LessonsCalendar(
        lessons: lessons,
        locale: localeAsync.value?.languageTag,
        onDayTapped: (selectedDay, dayLessons) =>
            _openLessonPage(context, selectedDay, dayLessons),
      ),
      loading: () => Skeletonizer(
        child: LessonsCalendar(
          lessons: lessonsAsync.value ?? _dummyLessons,
          locale: localeAsync.value?.languageTag,
        ),
      ),
      error: (error, stack) =>
          Center(child: Text('Error loading lessons: $error')),
    );
  }
}
