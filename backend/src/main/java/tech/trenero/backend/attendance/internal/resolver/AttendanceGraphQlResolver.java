package tech.trenero.backend.attendance.internal.resolver;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.codegen.types.Attendance;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.student.external.StudentSpi;

@Controller
@RequiredArgsConstructor
public class AttendanceGraphQlResolver {
  @Lazy private final LessonSpi lessonSpi;
  @Lazy private final StudentSpi studentSpi;

  @SchemaMapping(typeName = "Attendance", field = "lesson")
  public Lesson lesson(Attendance attendance, @AuthenticationPrincipal JwtUser jwtUser) {
    UUID lessonId = attendance.getLesson().getId();
    return lessonSpi.getLessonById(lessonId, jwtUser);
  }

  @SchemaMapping(typeName = "Attendance", field = "student")
  public Student student(Attendance attendance, @AuthenticationPrincipal JwtUser jwtUser) {
    UUID studentId = attendance.getStudent().getId();
    return studentSpi.getStudentById(studentId, jwtUser);
  }
}
