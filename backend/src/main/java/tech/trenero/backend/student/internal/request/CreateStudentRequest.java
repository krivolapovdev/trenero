package tech.trenero.backend.student.internal.request;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record CreateStudentRequest(
    @NotNull String fullName,
    LocalDate birthdate,
    String phone,
    String note,
    UUID groupId,
    OffsetDateTime joinedAt) {
  public CreateStudentRequest {
    joinedAt = groupId != null && joinedAt == null ? OffsetDateTime.now() : joinedAt;
  }
}
