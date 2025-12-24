package tech.trenero.backend.group.internal.resolver;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.student.external.StudentSpi;

@Controller
@RequiredArgsConstructor
public class GroupGraphQlResolver {
  @Lazy private final StudentSpi studentSpi;
  @Lazy private final LessonSpi lessonSpi;

  @SchemaMapping(typeName = "Group", field = "students")
  public List<StudentDto> students(GroupDto group, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentSpi.getStudentsByGroupId(group.id(), jwtUser);
  }

  @SchemaMapping(typeName = "Group", field = "lessons")
  public List<LessonDto> lessons(GroupDto group, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonSpi.getLessonsByGroupId(group.id(), jwtUser);
  }
}
