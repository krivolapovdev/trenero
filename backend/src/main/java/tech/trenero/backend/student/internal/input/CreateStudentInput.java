package tech.trenero.backend.student.internal.input;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;
import java.util.UUID;

public record CreateStudentInput(
    @NotNull @NotBlank @Size(max = 255) String fullName,
    LocalDate birthdate,
    @Size(max = 15) String phone,
    @Size(max = 1023) String note,
    UUID groupId) {}
