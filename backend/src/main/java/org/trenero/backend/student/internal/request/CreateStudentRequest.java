package org.trenero.backend.student.internal.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public record CreateStudentRequest(
    @NotBlank @Size(max = 255) String fullName,
    LocalDate birthdate,
    @Size(max = 15) String phone,
    @Size(max = 255) String note,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean free) {}
