package tech.trenero.backend.group.internal.resolver;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.student.external.StudentSpi;

@Controller
@RequiredArgsConstructor
public class GroupGraphQlResolver {
  @Lazy private final StudentSpi studentSpi;
  @Lazy private final LessonSpi lessonSpi;

  @SchemaMapping(typeName = "Group", field = "students")
  public List<Student> students(Group group, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentSpi.getStudentsByGroupId(group.getId(), jwtUser);
  }

  @SchemaMapping(typeName = "Group", field = "lessons")
  public List<Lesson> lessons(Group group, @AuthenticationPrincipal JwtUser jwtUser) {
    return lessonSpi.getLessonsByGroupId(group.getId(), jwtUser);
  }
}
