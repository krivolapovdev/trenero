import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
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
      groupId: 'placeholder',
    );
  });

  /// The lessons of the day oldest first, so the numbered rows of the day sheet
  /// keep the order the lessons were created in.
  @visibleForTesting
  static List<LessonResponse> dayLessonsOldestFirst(
    List<LessonResponse> dayLessons,
  ) => [...dayLessons]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  /// Opens the lessons of the tapped day.
  ///
  /// A day without a lesson opens the page that creates one straight away, the
  /// day sheet is only worth it when there are lessons to pick from.
  Future<void> _openDayLessons(
    BuildContext context,
    DateTime selectedDay,
    List<LessonResponse> dayLessons,
  ) async {
    if (dayLessons.isEmpty) {
      await _openLessonPage(context, selectedDay, null);
      return;
    }

    final selection = await AppBottomSheet.show<GroupDayLessonSelection>(
      context: context,
      child: GroupDayLessonsBottomSheet(
        groupLessons: dayLessonsOldestFirst(dayLessons),
      ),
    );

    if (selection == null || !context.mounted) return;

    await _openLessonPage(context, selectedDay, selection.lesson);
  }

  /// Opens the lesson page, or an empty page when the day has no lesson yet.
  Future<void> _openLessonPage(
    BuildContext context,
    DateTime selectedDay,
    LessonResponse? lesson,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            LessonPage(groupId: groupId, date: selectedDay, lesson: lesson),
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
            _openDayLessons(context, selectedDay, dayLessons),
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
