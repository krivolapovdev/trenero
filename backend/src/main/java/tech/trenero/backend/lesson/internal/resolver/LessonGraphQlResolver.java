package tech.trenero.backend.lesson.internal.resolver;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.attendance.external.AttendanceSpi;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.security.JwtUser;

@Controller
@RequiredArgsConstructor
public class LessonGraphQlResolver {
  private final AttendanceSpi attendanceSpi;

  @SchemaMapping(typeName = "Lesson", field = "attendances")
  public List<AttendanceDto> attendances(
      LessonDto lesson, @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceSpi.getAttendancesByLessonId(lesson.id(), jwtUser);
  }
}
