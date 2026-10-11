import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

class GroupDayLessonSelection {
  final LessonResponse? lesson;

  const new({this.lesson});
}

class GroupDayLessonsBottomSheet extends ConsumerWidget {
  final List<LessonResponse> groupLessons;

  const new({super.key, this.groupLessons = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (groupLessons.isNotEmpty) ...[
            Text(
              context.t.lessons.groupLessons,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            for (final (index, lesson) in groupLessons.indexed)
              _GroupLessonTile(
                key: ValueKey(lesson.id),
                number: index + 1,
                lesson: lesson,
              ),
          ],
          const _GroupCreateLessonTile(),
        ],
      ),
    ),
  );
}

class _GroupLessonTile extends ConsumerWidget {
  final int number;
  final LessonResponse lesson;

  const new({super.key, required this.number, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      '${context.t.lessons.groupLesson} $number',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: _AttendanceBadge(
      detailsState: ref.watch(lessonDetailsProvider(lesson.id)),
    ),
    onTap: () =>
        Navigator.of(context).pop(GroupDayLessonSelection(lesson: lesson)),
  );
}

class _GroupCreateLessonTile extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.add),
    title: Text(
      context.t.lessons.groupLesson,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () =>
        Navigator.of(context).pop(const GroupDayLessonSelection()),
  );
}

class _AttendanceBadge extends StatelessWidget {
  final AsyncValue<LessonDetailsResponse> detailsState;

  const new({required this.detailsState});

  @override
  Widget build(BuildContext context) {
    final visits = detailsState.value?.studentVisits;
    if (visits == null) return const SizedBox.shrink();

    final presentCount = visits
        .where((visit) => visit.status == VisitStatus.present)
        .length;
    final colorScheme = Theme.of(context).colorScheme;

    return CardBadge(
      icon: const Icon(Icons.check),
      label: '$presentCount/${visits.length}',
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
      foregroundColor: colorScheme.primary,
    );
  }
}
