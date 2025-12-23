package tech.trenero.backend.payment.internal.input;

import java.math.BigDecimal;
import java.util.UUID;

public record CreatePaymentInput(UUID studentId, BigDecimal amount) {}
