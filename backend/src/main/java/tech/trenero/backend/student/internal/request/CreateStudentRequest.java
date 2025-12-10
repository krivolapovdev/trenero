package tech.trenero.backend.student.internal.request;

import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record CreateStudentRequest(
    @NotBlank String fullName,
    String phone,
    LocalDate birthDate,
    String note,
    List<UUID> studentGroups) {
  public CreateStudentRequest {
    studentGroups = studentGroups == null ? List.of() : studentGroups;
  }
}
