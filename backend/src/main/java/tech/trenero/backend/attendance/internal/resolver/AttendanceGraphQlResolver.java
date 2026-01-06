package tech.trenero.backend.attendance.internal.resolver;

import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;

@Controller
@RequiredArgsConstructor
public class AttendanceGraphQlResolver {
  @Lazy private final LessonSpi lessonSpi;

  @SchemaMapping(typeName = "Attendance", field = "lesson")
  public Optional<LessonDto> attendances(
      AttendanceDto attendance, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonSpi.getLessonById(attendance.lessonId(), jwtUser);
  }
}
