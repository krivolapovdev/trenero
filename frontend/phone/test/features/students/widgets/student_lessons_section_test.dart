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
}) => VisitWithLessonResponse(
  visit: VisitResponse(
    id: 'visit-${lesson.id}',
    status: status,
    type: VisitType.regular,
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
        status: VisitStatus.absent,
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

    test('ignores the individual lesson', () {
      final individual = _visit(lesson: _lesson(id: 'individual-lesson'));

      expect(StudentLessonsSection.groupLessonsOf([individual]), isEmpty);
    });
  });

  group('showsIndividualCalendar', () {
    test('no lesson at all and no group keeps the individual calendar', () {
      expect(
        StudentLessonsSection.showsIndividualCalendar(const [], const []),
        isTrue,
      );
    });

    test('no lesson at all but a group leaves the group calendars alone', () {
      expect(
        StudentLessonsSection.showsIndividualCalendar(const [], [_group]),
        isFalse,
      );
    });

    test('individual lessons next to a group keep both calendars', () {
      final visits = [_visit(lesson: _lesson(id: 'individual'))];

      expect(
        StudentLessonsSection.showsIndividualCalendar(visits, [_group]),
        isTrue,
      );
    });

    test('individual and group lessons keep both calendars', () {
      final visits = [
        _visit(lesson: _lesson(id: 'individual')),
        _visit(
          lesson: _lesson(id: 'group', groupId: 'group-1'),
        ),
      ];

      expect(
        StudentLessonsSection.showsIndividualCalendar(visits, [_group]),
        isTrue,
      );
    });

    test('only group lessons drop the individual calendar', () {
      final visits = [
        _visit(
          lesson: _lesson(id: 'group', groupId: 'group-1'),
        ),
      ];

      expect(
        StudentLessonsSection.showsIndividualCalendar(visits, [_group]),
        isFalse,
      );
    });
  });

  group('opensCreatePageDirectly', () {
    test('a day without a lesson of the kind opens the create page', () {
      expect(
        StudentLessonsSection.opensCreatePageDirectly(
          StudentLessonsSection.dayVisitsOf(const [], _day),
        ),
        isTrue,
      );
    });

    test('a day with a lesson of the kind keeps the day sheet', () {
      final dayVisits = StudentLessonsSection.dayVisitsOf([
        _visit(lesson: _lesson(id: 'individual-lesson')),
      ], _day);

      expect(StudentLessonsSection.opensCreatePageDirectly(dayVisits), isFalse);
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
  });

  group('lessonVisitsOf', () {
    test('keeps the visits of a student', () {
      final lesson = _visit(lesson: _lesson(id: 'lesson'));

      expect(
        StudentLessonsSection.lessonVisitsOf([lesson])
            .map((visit) => visit.lesson.id),
        ['lesson'],
      );
    });
  });

  group('individualLessons', () {
    test('keeps the individual lessons of the student', () {
      final individual = _visit(lesson: _lesson(id: 'individual'));
      final group = _visit(
        lesson: _lesson(id: 'group', groupId: 'group-1'),
      );

      expect(
        StudentLessonsSection.individualLessons([individual, group])
            .map((lesson) => lesson.id),
        ['individual'],
      );
    });

    test('has no lesson on a student without individual lessons', () {
      final group = _visit(
        lesson: _lesson(id: 'group', groupId: 'group-1'),
      );

      expect(StudentLessonsSection.individualLessons([group]), isEmpty);
    });
  });

  group('groupLessons', () {
    test('keeps the lessons of the requested group', () {
      final groupA = _visit(
        lesson: _lesson(id: 'a', groupId: 'group-a'),
      );
      final groupB = _visit(
        lesson: _lesson(id: 'b', groupId: 'group-b'),
      );
      final individual = _visit(lesson: _lesson(id: 'individual'));

      expect(
        StudentLessonsSection.groupLessons([
          groupA,
          groupB,
          individual,
        ], 'group-a').map((lesson) => lesson.id),
        ['a'],
      );
    });
  });

  group('groupIdsOf', () {
    test('lists every group once, in the order its lessons start', () {
      final groupA = _visit(
        lesson: _lesson(id: 'a-1', groupId: 'group-a'),
      );
      final groupB = _visit(
        lesson: _lesson(id: 'b-1', groupId: 'group-b'),
      );
      final groupAAgain = _visit(
        lesson: _lesson(id: 'a-2', groupId: 'group-a'),
      );
      final individual = _visit(lesson: _lesson(id: 'individual'));

      expect(
        StudentLessonsSection.groupIdsOf([
          groupA,
          groupB,
          groupAAgain,
          individual,
        ]),
        ['group-a', 'group-b'],
      );
    });

    test('has no group on a student without group lessons', () {
      expect(
        StudentLessonsSection.groupIdsOf([
          _visit(lesson: _lesson(id: 'individual')),
        ]),
        isEmpty,
      );
    });
  });
}
