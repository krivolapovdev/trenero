package tech.trenero.backend.common.response;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record StudentResponse(
    UUID id,
    String fullName,
    LocalDate birthdate,
    String phone,
    String note,
    UUID groupId,
    OffsetDateTime createdAt) {}
