package tech.trenero.backend.payment.internal.input;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreatePaymentInput(
    @NotNull UUID studentId,
    @NotNull BigDecimal amount,
    @NotNull @Min(1) Integer lessonsPerPayment,
    @NotNull @PastOrPresent LocalDate date) {}
