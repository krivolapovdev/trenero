package tech.trenero.backend.student.external;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentValidator {
  void validateStudentIsPresentAndActive(UUID studentId, JwtUser jwtUser)
      throws EntityNotFoundException;

  void validateStudentIdsList(List<UUID> studentIds, JwtUser jwtUser)
      throws EntityNotFoundException;
}
