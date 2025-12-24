package tech.trenero.backend.common.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record StudentDto(
    UUID id,
    String fullName,
    OffsetDateTime createdAt,
    LocalDate birthDate,
    String phone,
    String note,
    UUID groupId,
    boolean deleted) {}
