package org.trenero.backend.payment.internal.request;

import java.math.BigDecimal;
import java.time.LocalDate;

public record UpdatePaymentRequest(BigDecimal amount, LocalDate paidUntil, LocalDate date) {}
