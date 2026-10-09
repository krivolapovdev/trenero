import 'package:flutter_test/flutter_test.dart';
import 'package:phone/features/students/widgets/student_lessons_section.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';

final DateTime _day = DateTime(2026, 10, 8);

final GroupResponse _group = GroupResponse(
  id: 'group-1',
  name: 'Group A',
  createdAt: _day,
);

LessonResponse _lesson({required String id, String? groupId, DateTime? date}) =>
    LessonResponse(
      id: id,
      date: date ?? _day,
      createdAt: _day,
      groupId: groupId,
    );

/// A visit of the student for [lesson], present by default.
VisitWithLessonResponse _visit({
  required LessonResponse lesson,
  VisitStatus status = VisitStatus.present,
  VisitType type = VisitType.regular,
}) => VisitWithLessonResponse(
  visit: VisitResponse(
    id: 'visit-${lesson.id}',
    status: status,
    type: type,
    lessonId: lesson.id,
    studentId: 'student-1',
    createdAt: _day,
  ),
  lesson: lesson,
);

void main() {
  group('dayVisitsOf', () {
    test('keeps the visits that take place on the day', () {
      final onDay = _visit(lesson: _lesson(id: 'on-day'));
      final onOtherDay = _visit(
        lesson: _lesson(id: 'other-day', date: DateTime(2026, 10, 9)),
      );

      final visits = StudentLessonsSection.dayVisitsOf([
        onDay,
        onOtherDay,
      ], _day);

      expect(visits.map((visit) => visit.lesson.id), ['on-day']);
    });

    test('has nothing to pick on a day without visits', () {
      expect(StudentLessonsSection.dayVisitsOf(const [], _day), isEmpty);
    });
  });

  group('individualLessonsOf', () {
    test('keeps the individual lessons with the attendance of the student', () {
      final attended = _visit(lesson: _lesson(id: 'individual-attended'));
      final missed = _visit(
        lesson: _lesson(id: 'individual-missed'),
        status: VisitStatus.unmarked,
      );

      final lessons = StudentLessonsSection.individualLessonsOf([
        attended,
        missed,
      ]);

      expect(lessons.map((lesson) => lesson.lesson.id), [
        'individual-attended',
        'individual-missed',
      ]);
      expect(lessons.map((lesson) => lesson.isPresent), [true, false]);
    });

    test('ignores the lessons of a group', () {
      final groupLesson = _visit(
        lesson: _lesson(id: 'group-lesson', groupId: 'group-1'),
      );

      expect(StudentLessonsSection.individualLessonsOf([groupLesson]), isEmpty);
    });
  });

  group('groupLessonsOf', () {
    test('keeps the group lessons with the attendance of the student', () {
      final attended = _visit(
        lesson: _lesson(id: 'group-attended', groupId: 'group-1'),
      );
      final missed = _visit(
        lesson: _lesson(id: 'group-missed', groupId: 'group-1'),
        status: VisitStatus.absent,
      );

      final groupLessons = StudentLessonsSection.groupLessonsOf([
        attended,
        missed,
      ]);

      expect(groupLessons.map((lesson) => lesson.lesson.id), [
        'group-attended',
        'group-missed',
      ]);
      expect(groupLessons.map((lesson) => lesson.isPresent), [true, false]);
    });

    test('an unmarked group lesson counts as missed', () {
      final unmarked = _visit(
        lesson: _lesson(id: 'group-unmarked', groupId: 'group-1'),
        status: VisitStatus.unmarked,
      );

      final groupLessons = StudentLessonsSection.groupLessonsOf([unmarked]);

      expect(groupLessons.single.isPresent, isFalse);
    });

    test('ignores the individual lesson', () {
      final individual = _visit(lesson: _lesson(id: 'individual-lesson'));

      expect(StudentLessonsSection.groupLessonsOf([individual]), isEmpty);
    });
  });

  group('opensCreatePageDirectly', () {
    test(
      'a student without a group and a day without lessons opens the page',
      () {
        expect(
          StudentLessonsSection.opensCreatePageDirectly(
            null,
            StudentLessonsSection.dayVisitsOf(const [], _day),
          ),
          isTrue,
        );
      },
    );

    test('a student with a group keeps the day sheet', () {
      expect(
        StudentLessonsSection.opensCreatePageDirectly(
          _group,
          StudentLessonsSection.dayVisitsOf(const [], _day),
        ),
        isFalse,
      );
    });

    test('a day with lessons keeps the day sheet', () {
      final dayVisits = StudentLessonsSection.dayVisitsOf([
        _visit(lesson: _lesson(id: 'individual-lesson')),
      ], _day);

      expect(
        StudentLessonsSection.opensCreatePageDirectly(null, dayVisits),
        isFalse,
      );
    });
  });

  group('dayVisitStatusesOf', () {
    test('keeps the attendance of the lesson visits of the day', () {
      final attended = _visit(lesson: _lesson(id: 'attended'));
      final missed = _visit(
        lesson: _lesson(id: 'missed'),
        status: VisitStatus.absent,
      );

      expect(
        StudentLessonsSection.dayVisitStatusesOf([attended, missed], _day),
        [VisitStatus.present, VisitStatus.absent],
      );
    });

    test('ignores the visits of the other days', () {
      final onOtherDay = _visit(
        lesson: _lesson(id: 'other-day', date: DateTime(2026, 10, 9)),
      );

      expect(
        StudentLessonsSection.dayVisitStatusesOf([onOtherDay], _day),
        isEmpty,
      );
    });

    test('ignores the visits that do not record a lesson', () {
      final unmarked = _visit(
        lesson: _lesson(id: 'not-a-lesson'),
        type: VisitType.unmarked,
      );

      expect(
        StudentLessonsSection.dayVisitStatusesOf([unmarked], _day),
        isEmpty,
      );
    });
  });
}
