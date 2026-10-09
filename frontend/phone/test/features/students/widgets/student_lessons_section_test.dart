import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/generated/models/lesson_response.dart';

final DateTime _day = DateTime(2026, 10, 8);

LessonResponse _lesson({required String id, String? groupId}) =>
    LessonResponse(id: id, date: _day, createdAt: _day, groupId: groupId);

void main() {
  group('individualLessonOf', () {
    test('picks the lesson that belongs to no group', () {
      final groupLesson = _lesson(id: 'group-lesson', groupId: 'group-1');
      final individualLesson = _lesson(id: 'individual-lesson');

      final picked = StudentLessonsSection.individualLessonOf([
        groupLesson,
        individualLesson,
      ]);

      expect(picked?.id, 'individual-lesson');
    });

    test('ignores the lessons of a group', () {
      final groupLessons = [
        _lesson(id: 'group-lesson-1', groupId: 'group-1'),
        _lesson(id: 'group-lesson-2', groupId: 'group-2'),
      ];

      expect(StudentLessonsSection.individualLessonOf(groupLessons), isNull);
    });

    test('has nothing to pick on a day without lessons', () {
      expect(StudentLessonsSection.individualLessonOf(const []), isNull);
    });
  });
}
