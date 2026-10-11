import 'package:flutter/material.dart';
import 'package:phone/core/widgets/day_colors.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_status.dart';

class LessonDayMarker extends StatelessWidget {
  static const double _margin = 4.0;
  static const double _dotSize = 5.0;
  static const double _dotGap = 2;

  final DateTime day;
  final List<LessonResponse> lessons;
  final List<VisitStatus>? visitStatuses;

  const new({
    super.key,
    required this.day,
    required this.lessons,
    this.visitStatuses,
  });

  @override
  Widget build(BuildContext context) {
    final colors = dayColors(visitStatuses, lessons);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(_margin),
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: TextStyle(
                  color: colors.foreground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: _dotGap),
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: colors.foreground,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
