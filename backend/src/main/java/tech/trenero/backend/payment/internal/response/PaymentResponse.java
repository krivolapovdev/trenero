package tech.trenero.backend.payment.internal.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record PaymentResponse(
    UUID id, UUID studentId, BigDecimal amount, LocalDateTime createdAt) {}
