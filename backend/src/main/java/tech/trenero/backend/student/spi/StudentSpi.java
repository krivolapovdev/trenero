package tech.trenero.backend.student.spi;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.response.StudentResponse;

public interface StudentSpi {
  List<StudentResponse> getStudentsByGroupId(UUID groupId);
}
