import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/features/groups/controllers/lesson_details_controller.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

/// The lesson the user picked in [GroupDayLessonsBottomSheet].
class GroupDayLessonSelection {
  /// The stored lesson to edit, or `null` to create a new lesson.
  final LessonResponse? lesson;

  const new({this.lesson});
}

/// The lessons of a day of a group.
///
/// A group can hold several lessons on the same day, so every lesson of the day
/// is listed on its own together with the attendance it has recorded: the
/// students that were present over the students the lesson holds. The row at the
/// bottom always creates another lesson of the day.
///
/// Pops with the [GroupDayLessonSelection] the user picked, or `null` when the
/// sheet is dismissed.
class GroupDayLessonsBottomSheet extends ConsumerWidget {
  /// The lessons of the day, oldest first.
  final List<LessonResponse> groupLessons;

  const new({super.key, this.groupLessons = const []});

  void _select(BuildContext context, GroupDayLessonSelection selection) =>
      Navigator.of(context).pop(selection);

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (groupLessons.isNotEmpty) ...[
            ...groupLessons.indexed.map(
              (entry) => _buildLessonTile(
                context,
                ref,
                number: entry.$1 + 1,
                lesson: entry.$2,
              ),
            ),
          ],
          _buildCreateTile(context),
        ],
      ),
    ),
  );

  Widget _buildLessonTile(
    BuildContext context,
    WidgetRef ref, {
    required int number,
    required LessonResponse lesson,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.groups_outlined),
    title: Text(
      '${context.t.lessons.groupLesson} $number',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: _buildAttendanceBadge(
      context,
      ref.watch(lessonDetailsProvider(lesson.id)),
    ),
    onTap: () => _select(context, GroupDayLessonSelection(lesson: lesson)),
  );

  Widget _buildCreateTile(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.add),
    title: Text(
      context.t.lessons.groupLesson,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => _select(context, const GroupDayLessonSelection()),
  );

  /// `3/12`: the students that were present over the students of the lesson.
  ///
  /// Nothing is shown while the attendance of the lesson is still loading.
  Widget _buildAttendanceBadge(
    BuildContext context,
    AsyncValue<LessonDetailsResponse> detailsState,
  ) {
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
