package tech.trenero.backend.visit.internal.resolver;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.codegen.types.Visit;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.student.external.StudentSpi;

@Controller
@RequiredArgsConstructor
public class VisitGraphQlResolver {
  @Lazy private final LessonSpi lessonSpi;
  @Lazy private final StudentSpi studentSpi;

  @SchemaMapping(typeName = "Visit", field = "lesson")
  public Lesson lesson(Visit visit, @AuthenticationPrincipal JwtUser jwtUser) {
    UUID lessonId = visit.getLesson().getId();
    return lessonSpi.getLessonById(lessonId, jwtUser);
  }

  @SchemaMapping(typeName = "Visit", field = "student")
  public Student student(Visit visit, @AuthenticationPrincipal JwtUser jwtUser) {
    UUID studentId = visit.getStudent().getId();
    return studentSpi.getStudentById(studentId, jwtUser);
  }
}
