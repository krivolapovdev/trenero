package tech.trenero.backend.common.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

public record AttendanceDto(
    UUID id, UUID lessonId, UUID studentId, boolean present, OffsetDateTime createdAt) {}
