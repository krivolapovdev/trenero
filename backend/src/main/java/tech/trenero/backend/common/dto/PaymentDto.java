package tech.trenero.backend.common.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PaymentDto(
    UUID id, UUID studentId, BigDecimal amount, OffsetDateTime createdAt, boolean deleted) {}
