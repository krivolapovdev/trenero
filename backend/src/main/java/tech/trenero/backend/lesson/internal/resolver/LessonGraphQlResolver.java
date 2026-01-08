package tech.trenero.backend.lesson.internal.resolver;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.attendance.external.AttendanceSpi;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;

@Controller
@RequiredArgsConstructor
public class LessonGraphQlResolver {
  @Lazy private final AttendanceSpi attendanceSpi;
  @Lazy private final GroupSpi groupSpi;

  @SchemaMapping(typeName = "Lesson", field = "attendances")
  public List<AttendanceDto> attendances(
      LessonDto lesson, @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceSpi.getAttendancesByLessonId(lesson.id(), jwtUser);
  }

  @SchemaMapping(typeName = "Lesson", field = "group")
  public GroupDto group(LessonDto lesson, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupSpi
        .getGroupById(lesson.groupId(), jwtUser)
        .orElseThrow(EntityNotFoundException::new);
  }
}
