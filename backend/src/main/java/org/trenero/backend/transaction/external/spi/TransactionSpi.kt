package org.trenero.backend.transaction.external.spi

import java.math.BigDecimal
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

  fun createStudentPayment(
    studentId: UUID,
    amount: BigDecimal,
    date: LocalDate,
    paidUntil: LocalDate,
    jwtUser: JwtUser,
  ): TransactionResponse

  fun deleteTransactionById(
    transactionId: UUID,
    jwtUser: JwtUser,
  )
}
