package org.trenero.backend.metric.internal.response

import io.swagger.v3.oas.annotations.media.Schema
import java.math.BigDecimal
import java.time.LocalDate

data class PaymentMetricResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val date: LocalDate,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val total: BigDecimal,
)
