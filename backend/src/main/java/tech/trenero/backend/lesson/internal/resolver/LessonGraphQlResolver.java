package tech.trenero.backend.lesson.internal.resolver;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.codegen.types.Lesson;
import tech.trenero.backend.codegen.types.Visit;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.visit.external.VisitSpi;

@Controller
@RequiredArgsConstructor
public class LessonGraphQlResolver {
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final GroupSpi groupSpi;

  @SchemaMapping(typeName = "Lesson", field = "visits")
  public List<Visit> visits(Lesson lesson, @AuthenticationPrincipal JwtUser jwtUser) {
    return visitSpi.getVisitsByLessonId(lesson.getId(), jwtUser);
  }

  @SchemaMapping(typeName = "Lesson", field = "group")
  public Group group(Lesson lesson, @AuthenticationPrincipal JwtUser jwtUser) {
    UUID groupId = lesson.getGroup().getId();
    return groupSpi.getGroupById(groupId, jwtUser);
  }
}
