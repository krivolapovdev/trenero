package tech.trenero.backend.common.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record GroupDto(
    UUID id, String name, OffsetDateTime createdAt, BigDecimal defaultPrice, boolean deleted) {}
