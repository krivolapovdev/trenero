package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record LessonResponse(
    @NotNull UUID id,
    @NotNull UUID groupId,
    @NotNull LocalDate date,
    @NotNull OffsetDateTime createdAt) {}
