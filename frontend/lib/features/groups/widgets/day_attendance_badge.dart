import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/core/widgets/card_badge.dart';
import 'package:phone/generated/models/lesson_details_response.dart';
import 'package:phone/generated/models/visit_status.dart';

class DayAttendanceBadge extends StatelessWidget {
  final AsyncValue<LessonDetailsResponse> detailsState;

  const new({super.key, required this.detailsState});

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
