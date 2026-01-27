package tech.trenero.backend.metric.internal.response;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;

public record MonthlyPaymentMetricResponse(@NotNull LocalDate date, @NotNull BigDecimal total) {}
