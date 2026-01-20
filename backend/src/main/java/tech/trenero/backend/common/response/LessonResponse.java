package tech.trenero.backend.common.response;

import java.time.OffsetDateTime;
import java.util.UUID;

public record LessonResponse(
    UUID id, UUID groupId, OffsetDateTime startDateTime, OffsetDateTime createdAt) {}
