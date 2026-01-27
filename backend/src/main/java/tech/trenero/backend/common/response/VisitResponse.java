package tech.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.UUID;

public record VisitResponse(
    @NotNull UUID id,
    @NotNull Boolean present,
    @NotNull UUID lessonId,
    @NotNull UUID studentId,
    @NotNull OffsetDateTime createdAt) {}
