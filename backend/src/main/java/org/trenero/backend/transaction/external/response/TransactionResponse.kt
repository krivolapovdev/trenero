package org.trenero.backend.transaction.external.response

import io.swagger.v3.oas.annotations.media.Schema
import java.math.BigDecimal
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID
import org.trenero.backend.common.domain.TransactionType

data class TransactionResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val id: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val amount: BigDecimal,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val date: LocalDate,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val type: TransactionType,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val createdAt: OffsetDateTime,
  val paymentDetails: PaymentDetailsResponse? = null,
)
