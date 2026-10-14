package org.trenero.backend.metric.internal.response

import io.swagger.v3.oas.annotations.media.Schema
import java.math.BigDecimal
import java.time.OffsetDateTime

data class PaymentMetricResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val date: OffsetDateTime,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val total: BigDecimal,
)
