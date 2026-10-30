import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/errors/dio_error_mapper.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/app_bottom_sheet.dart';
import 'package:phone/core/widgets/create_lesson_button.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';
import 'package:phone/features/groups/pages/lesson_page.dart';
import 'package:phone/features/groups/widgets/group_day_lessons_bottom_sheet.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupLessonsSection extends ConsumerWidget {
  final String groupId;

  final String? groupName;

  const new({super.key, required this.groupId, this.groupName});

  static final List<LessonResponse> _dummyLessons = List.generate(6, (index) {
    final date = DateTime.now().add(Duration(days: index * 3));
    return LessonResponse(
      id: 'placeholder-$index',
      date: date,
      createdAt: date,
      groupId: 'placeholder',
    );
  });

  @visibleForTesting
  static List<LessonResponse> dayLessonsOldestFirst(
    List<LessonResponse> dayLessons,
  ) => [...dayLessons]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Future<void> _openDayLessons(
    BuildContext context,
    DateTime selectedDay,
    List<LessonResponse> dayLessons,
  ) async {
    if (dayLessons.isEmpty) {
      await _openLessonPage(context, selectedDay, null);
      return;
    }

    if (dayLessons.length == 1) {
      await _openLessonPage(context, selectedDay, dayLessons.first);
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

  Future<void> _openLessonPage(
    BuildContext context,
    DateTime selectedDay,
    LessonResponse? lesson,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonPage(
          groupId: groupId,
          groupName: groupName,
          date: selectedDay,
          lesson: lesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(groupLessonsProvider(groupId));
    final isLoadingEarlier = ref.watch(
      groupLessonsLoadingEarlierProvider(groupId),
    );
    final focusedDay = ref.watch(groupLessonsMonthProvider(groupId));
    final locale = ref.watch(languageProvider).value?.languageTag;

    if (lessonsAsync.hasError && !lessonsAsync.hasValue) {
      return Center(
        child: Text(
          context.t.lessons.errorLoading(
            error: lessonsAsync.error!.userMessage(context.t),
          ),
        ),
      );
    }

    return Skeletonizer(
      enabled: lessonsAsync.isLoading || isLoadingEarlier,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            LessonsCalendar(
              lessons: lessonsAsync.value ?? _dummyLessons,
              locale: locale,
              focusedDay: focusedDay,
              onMonthChanged: (month) {
                ref
                    .read(groupLessonsMonthProvider(groupId).notifier)
                    .show(month);
                ref
                    .read(groupLessonsProvider(groupId).notifier)
                    .loadEarlierMonths(month);
              },
              onDayTapped: (selectedDay, dayLessons) =>
                  _openDayLessons(context, selectedDay, dayLessons),
              surfaceVisible: false,
              swipeEnabled: false,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CreateLessonButton(
                onPressed: () => _openLessonPage(context, DateTime.now(), null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
