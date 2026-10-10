package org.trenero.backend.student.internal.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;

public record CreateStudentRequest(
    @NotNull String fullName,
    LocalDate birthdate,
    String phone,
    String note,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED) boolean free) {}
