package org.trenero.backend.metric.internal.service

import java.math.BigDecimal
import java.time.OffsetDateTime
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Lazy
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.server.ResponseStatusException
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.metric.internal.domain.MetricScope
import org.trenero.backend.metric.internal.response.PaymentMetricResponse
import org.trenero.backend.transaction.external.spi.TransactionSpi

@Service
class MetricService(@Lazy private val transactionSpi: TransactionSpi) {
  private val log = LoggerFactory.getLogger(javaClass)

  @Transactional(readOnly = true)
  fun getPaymentStatistics(
    scope: MetricScope,
    startDate: OffsetDateTime,
    endDate: OffsetDateTime,
    jwtUser: JwtUser,
  ): List<PaymentMetricResponse> {
    log.info(
      "Calculating statistics: scope={}, range=[{} to {}], user={}",
      scope,
      startDate,
      endDate,
      jwtUser,
    )

    if (endDate.isBefore(startDate)) {
      throw ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "endDate must not be before startDate",
      )
    }

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

    // The number of points follows from the range alone, and the range comes from the caller: the
    // walk is stopped at the limit instead of building a list of a size nobody can serve.
    val points =
      generateSequence(startBucket) { scope.next(it) }
        .takeWhile { !it.isAfter(endBucket) }
        .take(MAX_PERIODS + 1)
        .map { bucket ->
          PaymentMetricResponse(
            date = bucket,
            total = totalsByBucket[bucket] ?: BigDecimal.ZERO,
          )
        }
        .toList()

    if (points.size > MAX_PERIODS) {
      throw ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "the range covers more than $MAX_PERIODS periods, narrow it down",
      )
    }

    return points
  }

  private companion object {
    /** Far beyond any chart a client draws, small enough to stay bounded for any input. */
    const val MAX_PERIODS = 5000
  }
}
