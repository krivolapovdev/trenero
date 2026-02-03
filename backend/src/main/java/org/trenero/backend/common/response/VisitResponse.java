package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.trenero.backend.common.domain.VisitStatus;

public record VisitResponse(
    @NotNull UUID id,
    @NotNull VisitStatus status,
    @NotNull UUID lessonId,
    @NotNull UUID studentId,
    @NotNull OffsetDateTime createdAt) {}
