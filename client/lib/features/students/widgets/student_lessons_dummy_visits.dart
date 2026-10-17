import 'package:phone/generated/models/lesson_response.dart';
import 'package:phone/generated/models/visit_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/generated/models/visit_with_lesson_response.dart';

final List<VisitWithLessonResponse> studentLessonsDummyVisits = List.generate(
  6,
  (index) {
    final date = DateTime.now().add(Duration(days: index * 3));
    final lesson = LessonResponse(
      id: 'placeholder-$index',
      date: date,
      createdAt: date,
      groupId: index.isOdd ? 'placeholder-group' : null,
    );

    return VisitWithLessonResponse(
      visit: VisitResponse(
        id: 'placeholder-visit-$index',
        status: VisitStatus.present,
        type: VisitType.regular,
        lessonId: lesson.id,
        studentId: 'placeholder-student',
        createdAt: date,
      ),
      lesson: lesson,
    );
  },
);
