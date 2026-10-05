package org.trenero.backend.transaction.internal.request

import jakarta.validation.Valid
import jakarta.validation.constraints.NotNull
import java.math.BigDecimal
import java.time.LocalDate
import org.trenero.backend.common.domain.TransactionType

data class CreateTransactionRequest(
  @get:NotNull val amount: BigDecimal,
  @get:NotNull val date: LocalDate,
  @get:NotNull val type: TransactionType,
  @get:Valid val paymentDetails: CreatePaymentDetailsRequest? = null,
)
