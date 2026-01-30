package tech.trenero.backend.payment.internal.request;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreatePaymentRequest(
    @NotNull UUID studentId,
    @NotNull BigDecimal amount,
    @NotNull Integer paidLessons,
    @NotNull LocalDate date) {}
