package org.trenero.backend.student.internal.request

import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.PastOrPresent
import java.math.BigDecimal
import java.time.OffsetDateTime

data class CreateStudentPaymentRequest(
  @get:NotNull val amount: BigDecimal,
  @get:NotNull @get:PastOrPresent val date: OffsetDateTime,
  @get:NotNull val paidUntil: OffsetDateTime,
)
