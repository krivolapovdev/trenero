package org.trenero.backend.payment.external

import java.time.LocalDate
import org.trenero.backend.common.response.TransactionResponse
import org.trenero.backend.common.security.JwtUser

interface TransactionSpi {
  fun getTransactionsByDateRange(
    startDate: LocalDate,
    endDate: LocalDate,
    jwtUser: JwtUser,
  ): List<TransactionResponse>
}
