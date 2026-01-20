package tech.trenero.backend.common.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record VisitResponse(
    UUID id, Boolean present, UUID lessonId, UUID studentId, OffsetDateTime createdAt) {}
