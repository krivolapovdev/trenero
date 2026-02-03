package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public record GroupResponse(
    @NotNull UUID id,
    @NotNull String name,
    BigDecimal defaultPrice,
    String note,
    @NotNull OffsetDateTime createdAt) {}
