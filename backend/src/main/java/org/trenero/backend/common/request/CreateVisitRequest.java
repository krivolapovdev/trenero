package org.trenero.backend.common.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;

public record CreateVisitRequest(
    @NotNull UUID lessonId,
    @NotNull UUID studentId,
    @NotNull VisitStatus status,
    @NotNull VisitType type) {}
