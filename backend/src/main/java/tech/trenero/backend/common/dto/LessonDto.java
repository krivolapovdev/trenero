package tech.trenero.backend.common.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record LessonDto(
    UUID id, UUID groupId, OffsetDateTime startDateTime, OffsetDateTime createdAt) {}
