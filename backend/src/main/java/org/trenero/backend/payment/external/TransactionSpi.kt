package org.trenero.backend.payment.external

import java.time.LocalDate
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.payment.external.response.TransactionResponse

interface TransactionSpi {
  fun getTransactionsByDateRange(
    startDate: LocalDate,
    endDate: LocalDate,
    jwtUser: JwtUser,
  ): List<TransactionResponse>
}
