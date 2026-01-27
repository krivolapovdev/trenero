package tech.trenero.backend.payment.internal.request;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreatePaymentRequest(
    UUID studentId, BigDecimal amount, Integer paidLessons, LocalDate date) {}
