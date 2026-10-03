package org.trenero.backend.metric.internal.response

import java.math.BigDecimal
import java.time.LocalDate

data class PaymentMetricResponse(
  val date: LocalDate,
  val total: BigDecimal,
)
