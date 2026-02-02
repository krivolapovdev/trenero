package tech.trenero.backend.payment.internal.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateStudentPaymentRequest(
    @NotNull UUID studentId,
    @NotNull BigDecimal amount,
    @NotNull @Min(1) Integer paidLessons,
    @NotNull @PastOrPresent LocalDate date) {}
