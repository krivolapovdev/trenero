package org.trenero.backend.metric.internal.response;

import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.YearMonth;

public record MonthlyPaymentMetricResponse(@NotNull YearMonth date, @NotNull BigDecimal total) {}
