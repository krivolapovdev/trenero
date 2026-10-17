import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/groups/widgets/group_lessons_section.dart';
import 'package:phone/generated/models/lesson_response.dart';

final DateTime _day = DateTime(2026, 10, 8);

LessonResponse _lesson({required String id, required DateTime createdAt}) =>
    LessonResponse(
      id: id,
      date: _day,
      createdAt: createdAt,
      groupId: 'group-1',
    );

void main() {
  group('dayLessonsOldestFirst', () {
    test('orders the lessons of the day the way they were created', () {
      final morning = _lesson(id: 'morning', createdAt: _day);
      final evening = _lesson(
        id: 'evening',
        createdAt: _day.add(const Duration(hours: 9)),
      );

      final lessons = GroupLessonsSection.dayLessonsOldestFirst([
        evening,
        morning,
      ]);

      expect(lessons.map((lesson) => lesson.id), ['morning', 'evening']);
    });

    test('has nothing to order on a day without lessons', () {
      expect(GroupLessonsSection.dayLessonsOldestFirst(const []), isEmpty);
    });
  });
}
