package tech.trenero.backend.student.internal.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record CreateStudentRequest(
    @NotBlank @Size(max = 255) String fullName,
    @Size(max = 15) String phone,
    LocalDate birthDate,
    @Size(max = 1023) String note,
    List<UUID> studentGroups) {
  public CreateStudentRequest {
    studentGroups = studentGroups == null ? List.of() : studentGroups;
  }
}
