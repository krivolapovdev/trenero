package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;

public record VisitResponse(
    @NotNull UUID id,
    @NotNull VisitStatus status,
    @NotNull VisitType type,
    @NotNull UUID lessonId,
    @NotNull UUID studentId,
    @NotNull OffsetDateTime createdAt) {}
