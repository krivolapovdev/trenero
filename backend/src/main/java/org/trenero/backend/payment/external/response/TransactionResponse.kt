package org.trenero.backend.payment.external.response

import jakarta.validation.constraints.NotNull
import java.math.BigDecimal
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.payment.internal.response.TransactionStudentPaymentResponse

data class TransactionResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val amount: BigDecimal,
  @get:NotNull val date: LocalDate,
  @get:NotNull val type: TransactionType,
  @get:NotNull val createdAt: OffsetDateTime,
  val studentPayment: TransactionStudentPaymentResponse?,
)
