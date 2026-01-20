package tech.trenero.backend.visit.internal.request;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CreateVisitRequest(
    @NotNull UUID lessonId, @NotNull UUID studentId, @NotNull Boolean present) {}
