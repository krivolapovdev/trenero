package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record StudentResponse(
    @NotNull UUID id,
    @NotNull String fullName,
    LocalDate birthdate,
    String phone,
    String note,
    @NotNull OffsetDateTime createdAt) {}
