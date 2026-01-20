package tech.trenero.backend.common.response;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

public record PaymentResponse(
    UUID id,
    UUID studentId,
    BigDecimal amount,
    Integer lessonsPerPayment,
    LocalDate date,
    OffsetDateTime createdAt) {}
