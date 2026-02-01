package tech.trenero.backend.common.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CreateVisitRequest(
    @NotNull UUID lessonId, @NotNull UUID studentId, @NotNull Boolean present) {}
