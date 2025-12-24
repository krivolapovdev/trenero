package tech.trenero.backend.payment.internal.input;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

public record CreatePaymentInput(@NotNull UUID studentId, @NotNull BigDecimal amount) {}
