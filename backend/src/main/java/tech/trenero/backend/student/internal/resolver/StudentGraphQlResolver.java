package tech.trenero.backend.student.internal.resolver;

import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.student.internal.entity.Student;

@Controller
@RequiredArgsConstructor
public class StudentGraphQlResolver {
  @Lazy private final GroupSpi groupSpi;

  @SchemaMapping(typeName = "Student", field = "group")
  public Optional<GroupDto> getGroup(Student student, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupSpi.getGroupById(student.getGroupId(), jwtUser);
  }
}
