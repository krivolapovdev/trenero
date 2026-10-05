package org.trenero.backend.payment.external.response

import jakarta.validation.constraints.NotNull
import java.math.BigDecimal
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID

data class StudentPaymentResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val studentId: UUID,
  @get:NotNull val amount: BigDecimal,
  @get:NotNull val date: LocalDate,
  val paidFrom: LocalDate?,
  @get:NotNull val paidUntil: LocalDate,
  @get:NotNull val createdAt: OffsetDateTime,
)
