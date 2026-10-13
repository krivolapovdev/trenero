package org.trenero.backend.student.internal.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import java.time.LocalDate;

public record CreateStudentRequest(
    @NotBlank String fullName,
    LocalDate birthdate,
    String phone,
    String note,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean free) {}
