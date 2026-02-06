package org.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record StudentPaymentResponse(
    @NotNull UUID id,
    @NotNull UUID studentId,
    @NotNull BigDecimal amount,
    @NotNull LocalDate date,
    LocalDate paidFrom,
    @NotNull LocalDate paidUntil,
    @NotNull OffsetDateTime createdAt) {}
