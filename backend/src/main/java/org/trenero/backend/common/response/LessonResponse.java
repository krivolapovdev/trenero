package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.UUID;

public record LessonResponse(
    @NotNull UUID id,
    @NotNull UUID groupId,
    @NotNull OffsetDateTime startDateTime,
    @NotNull OffsetDateTime createdAt) {}
