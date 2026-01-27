package tech.trenero.backend.common.response;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PaymentResponse(
    @NotNull UUID id,
    @NotNull UUID studentId,
    @NotNull BigDecimal amount,
    @NotNull Integer paidLessons,
    @NotNull LocalDate date,
    @NotNull OffsetDateTime createdAt) {}
