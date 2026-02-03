package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.trenero.backend.common.domain.TransactionType;

public record TransactionResponse(
    @NotNull UUID id,
    @NotNull BigDecimal amount,
    @NotNull LocalDate date,
    @NotNull TransactionType type,
    @NotNull OffsetDateTime createdAt) {}
