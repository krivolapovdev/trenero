package org.trenero.backend.transaction.external

import java.time.LocalDate
import java.util.UUID
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.transaction.external.response.TransactionResponse

interface TransactionSpi {
  fun getTransactionsByDateRange(
    startDate: LocalDate,
    endDate: LocalDate,
    jwtUser: JwtUser,
  ): List<TransactionResponse>

  fun getTransactionsByStudentId(
    studentId: UUID,
    jwtUser: JwtUser,
  ): List<TransactionResponse>

  fun getTransactionsByStudentIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, List<TransactionResponse>>

  fun deleteTransactionById(
    transactionId: UUID,
    jwtUser: JwtUser,
  )
}
