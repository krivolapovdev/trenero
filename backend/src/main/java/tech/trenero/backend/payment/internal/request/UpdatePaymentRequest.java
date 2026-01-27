package tech.trenero.backend.payment.internal.request;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;

public record UpdatePaymentRequest(
    Optional<BigDecimal> amount, Optional<Integer> paidLessons, Optional<LocalDate> date) {}
