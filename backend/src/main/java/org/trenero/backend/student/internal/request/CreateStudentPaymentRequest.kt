package org.trenero.backend.student.internal.request

import jakarta.validation.constraints.NotNull
import java.math.BigDecimal
import java.time.LocalDate

data class CreateStudentPaymentRequest(
  @get:NotNull val amount: BigDecimal,
  @get:NotNull val date: LocalDate,
  @get:NotNull val paidUntil: LocalDate,
)
