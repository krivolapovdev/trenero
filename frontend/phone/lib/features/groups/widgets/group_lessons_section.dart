import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/core/widgets/lessons_calendar.dart';
import 'package:phone/features/groups/controllers/group_lessons_controller.dart';

class GroupLessonsSection extends ConsumerWidget {
  final String groupId;

  const new({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(groupLessonsProvider(groupId));
    final localeAsync = ref.watch(languageProvider);

    return lessonsAsync.when(
      data: (lessons) => LessonsCalendar(
        lessons: lessons,
        locale: localeAsync.value?.languageTag,
        onDaySelected: (selectedDay, focusedDay) {},
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading lessons: $error')),
    );
  }
}
