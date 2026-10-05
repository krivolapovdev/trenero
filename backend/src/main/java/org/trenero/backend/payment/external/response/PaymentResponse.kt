package org.trenero.backend.payment.external.response

import jakarta.validation.constraints.NotNull
import java.math.BigDecimal
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID

data class PaymentResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val studentId: UUID,
  @get:NotNull val amount: BigDecimal,
  @get:NotNull val paidLessons: Int,
  @get:NotNull val date: LocalDate,
  @get:NotNull val createdAt: OffsetDateTime,
)
