package org.trenero.backend.payment.internal.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateStudentPaymentRequest(
    @NotNull UUID studentId,
    @NotNull BigDecimal amount,
    @NotNull @PastOrPresent LocalDate date,
    @NotNull LocalDate paidUntil) {}
