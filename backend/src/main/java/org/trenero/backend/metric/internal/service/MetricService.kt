package org.trenero.backend.metric.internal.service

import java.math.BigDecimal
import java.time.LocalDate
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Lazy
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.metric.internal.domain.MetricScope
import org.trenero.backend.metric.internal.response.PaymentMetricResponse
import org.trenero.backend.payment.external.TransactionSpi

@Service
class MetricService(@Lazy private val transactionSpi: TransactionSpi) {
  private val log = LoggerFactory.getLogger(javaClass)

  @Transactional(readOnly = true)
  fun getPaymentStatistics(
    scope: MetricScope,
    startDate: LocalDate,
    endDate: LocalDate,
    jwtUser: JwtUser,
  ): List<PaymentMetricResponse> {
    log.info(
      "Calculating statistics: scope={}, range=[{} to {}], user={}",
      scope,
      startDate,
      endDate,
      jwtUser,
    )

    val totalsByBucket =
      transactionSpi
        .getTransactionsByDateRange(startDate, endDate, jwtUser)
        .groupingBy { scope.truncate(it.date) }
        .fold(BigDecimal.ZERO) { acc, tr ->
          val amount = if (tr.type == TransactionType.INCOME) tr.amount else tr.amount.negate()
          acc + amount
        }

    val startBucket = scope.truncate(startDate)
    val endBucket = scope.truncate(endDate)

    return generateSequence(startBucket) { scope.next(it) }
      .takeWhile { !it.isAfter(endBucket) }
      .map { bucket ->
        PaymentMetricResponse(
          date = bucket,
          total = totalsByBucket[bucket] ?: BigDecimal.ZERO,
        )
      }
      .toList()
  }
}
