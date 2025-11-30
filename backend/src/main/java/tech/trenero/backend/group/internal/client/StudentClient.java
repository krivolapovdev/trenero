package tech.trenero.backend.group.internal.client;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.external.StudentSpi;

@Component
@RequiredArgsConstructor
public class StudentClient {
  @Lazy private final StudentSpi studentSpi;

  public List<StudentResponse> getStudentsByGroupId(UUID groupId) {
    return studentSpi.getStudentsByGroupId(groupId);
  }
}
