package tech.trenero.backend.attendance.internal.resolver;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.student.external.StudentSpi;

@Controller
@RequiredArgsConstructor
public class AttendanceGraphQlResolver {
  @Lazy private final LessonSpi lessonSpi;
  @Lazy private final StudentSpi studentSpi;

  @SchemaMapping(typeName = "Attendance", field = "lesson")
  public LessonDto attendances(AttendanceDto attendance, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonSpi
        .getLessonById(attendance.lessonId(), jwtUser)
        .orElseThrow(EntityNotFoundException::new);
  }

  @SchemaMapping(typeName = "Attendance", field = "student")
  public StudentDto student(AttendanceDto attendance, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentSpi
        .getStudentById(attendance.studentId(), jwtUser)
        .orElseThrow(EntityNotFoundException::new);
  }
}
