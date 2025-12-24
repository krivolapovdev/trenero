package tech.trenero.backend.student.internal.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.UUID;

public record CreateStudentInput(
    @NotNull @NotBlank @Size(max = 255) String fullName,
    LocalDate birthDate,
    String phone,
    String note,
    UUID groupId) {}
