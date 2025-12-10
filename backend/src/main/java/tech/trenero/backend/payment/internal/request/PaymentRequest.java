package tech.trenero.backend.payment.internal.request;

import java.math.BigDecimal;
import java.util.UUID;

public record PaymentRequest(UUID studentId, BigDecimal amount) {}
