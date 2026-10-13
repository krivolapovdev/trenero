package org.trenero.backend.metric.internal.service

import java.math.BigDecimal
import java.time.LocalDate
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.mockito.Mockito
import org.mockito.Mockito.mock
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import org.trenero.backend.common.domain.TransactionType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.metric.internal.domain.MetricScope
import org.trenero.backend.metric.internal.response.PaymentMetricResponse
import org.trenero.backend.transaction.external.response.TransactionResponse
import org.trenero.backend.transaction.external.spi.TransactionSpi

/**
 * The profit chart of the finance page: the transactions of the owner are folded into one point per
 * period, a period without a transaction reads zero, and the points run from the period of the
 * start date to the period of the end date.
 */
class MetricServiceGetPaymentStatisticsTest {

  private val createdAt = OffsetDateTime.of(2026, 10, 8, 12, 0, 0, 0, ZoneOffset.UTC)
  private val jwtUser = JwtUser(UUID.randomUUID(), "owner@example.com")
  private val transactionSpi = mock(TransactionSpi::class.java)
  private val service = MetricService(transactionSpi)

  @Test
  fun returnsAPointForEveryPeriodOfTheRange() {
    givenTransactions(
      LocalDate.of(2026, 6, 1),
      LocalDate.of(2026, 9, 30),
      transaction(LocalDate.of(2026, 8, 15), "1000.00", TransactionType.INCOME),
    )

    val points =
      service.getPaymentStatistics(
        MetricScope.MONTH,
        LocalDate.of(2026, 6, 1),
        LocalDate.of(2026, 9, 30),
        jwtUser,
      )

    assertThat(points.map { it.date })
      .containsExactly(
        LocalDate.of(2026, 6, 1),
        LocalDate.of(2026, 7, 1),
        LocalDate.of(2026, 8, 1),
        LocalDate.of(2026, 9, 1),
      )
    assertThat(totals(points))
      .containsExactly(
        BigDecimal.ZERO,
        BigDecimal.ZERO,
        BigDecimal("1000.00"),
        BigDecimal.ZERO,
      )
  }

  @Test
  fun foldsIncomeAndExpenseIntoTheProfitOfThePeriod() {
    givenTransactions(
      LocalDate.of(2026, 8, 1),
      LocalDate.of(2026, 8, 31),
      transaction(LocalDate.of(2026, 8, 1), "1000.00", TransactionType.INCOME),
      transaction(LocalDate.of(2026, 8, 2), "200.00", TransactionType.EXPENSE),
      transaction(LocalDate.of(2026, 8, 31), "50.00", TransactionType.INCOME),
    )

    val points =
      service.getPaymentStatistics(
        MetricScope.MONTH,
        LocalDate.of(2026, 8, 1),
        LocalDate.of(2026, 8, 31),
        jwtUser,
      )

    assertThat(points).hasSize(1)
    assertThat(totals(points)).containsExactly(BigDecimal("850.00"))
  }

  @Test
  fun reportsALossAsANegativePoint() {
    givenTransactions(
      LocalDate.of(2026, 8, 1),
      LocalDate.of(2026, 8, 31),
      transaction(LocalDate.of(2026, 8, 2), "300.00", TransactionType.EXPENSE),
    )

    val points =
      service.getPaymentStatistics(
        MetricScope.MONTH,
        LocalDate.of(2026, 8, 1),
        LocalDate.of(2026, 8, 31),
        jwtUser,
      )

    assertThat(totals(points)).containsExactly(BigDecimal("-300.00"))
  }

  @Test
  fun keepsTheDaysOfARangeInsideOnePeriodTogether() {
    givenTransactions(
      LocalDate.of(2026, 10, 5),
      LocalDate.of(2026, 10, 20),
      transaction(LocalDate.of(2026, 10, 20), "120.00", TransactionType.INCOME),
    )

    val points =
      service.getPaymentStatistics(
        MetricScope.MONTH,
        LocalDate.of(2026, 10, 5),
        LocalDate.of(2026, 10, 20),
        jwtUser,
      )

    assertThat(points.map { it.date }).containsExactly(LocalDate.of(2026, 10, 1))
    assertThat(totals(points)).containsExactly(BigDecimal("120.00"))
  }

  @Test
  fun foldsAWeekIntoItsMonday() {
    givenTransactions(
      LocalDate.of(2026, 10, 8),
      LocalDate.of(2026, 10, 20),
      transaction(LocalDate.of(2026, 10, 20), "700.00", TransactionType.INCOME),
    )

    val points =
      service.getPaymentStatistics(
        MetricScope.WEEK,
        LocalDate.of(2026, 10, 8),
        LocalDate.of(2026, 10, 20),
        jwtUser,
      )

    // 2026-10-08 is a Thursday and 2026-10-20 a Tuesday, so the weeks run from 2026-10-05.
    assertThat(points.map { it.date })
      .containsExactly(
        LocalDate.of(2026, 10, 5),
        LocalDate.of(2026, 10, 12),
        LocalDate.of(2026, 10, 19),
      )
    assertThat(totals(points))
      .containsExactly(BigDecimal.ZERO, BigDecimal.ZERO, BigDecimal("700.00"))
  }

  @Test
  fun readsTheTransactionsOfTheCallerForTheWholeRange() {
    givenTransactions(LocalDate.of(2026, 8, 1), LocalDate.of(2026, 8, 31))

    service.getPaymentStatistics(
      MetricScope.MONTH,
      LocalDate.of(2026, 8, 1),
      LocalDate.of(2026, 8, 31),
      jwtUser,
    )

    Mockito.verify(transactionSpi)
      .getTransactionsByDateRange(LocalDate.of(2026, 8, 1), LocalDate.of(2026, 8, 31), jwtUser)
  }

  @Test
  fun rejectsAReversedRange() {
    givenTransactions(LocalDate.of(2026, 8, 1), LocalDate.of(2026, 10, 1))

    val thrown = catchThrowable {
      service.getPaymentStatistics(
        MetricScope.MONTH,
        LocalDate.of(2026, 10, 1),
        LocalDate.of(2026, 8, 1),
        jwtUser,
      )
    }

    assertBadRequest(thrown)
  }

  /**
   * The number of points follows from the range alone, so a range of an extreme width used to build
   * a list of millions of points for one request: the work and the memory of the server were chosen
   * by the caller.
   */
  @Test
  fun rejectsARangeThatCoversTooManyPeriods() {
    val start = LocalDate.of(-9999, 1, 1)
    val end = LocalDate.of(9999, 12, 31)
    givenTransactions(start, end)

    val thrown = catchThrowable {
      service.getPaymentStatistics(MetricScope.WEEK, start, end, jwtUser)
    }

    assertBadRequest(thrown)
  }

  @Test
  fun acceptsAChartOfGenerousWidth() {
    val start = LocalDate.of(2026, 1, 1)
    val end = LocalDate.of(2036, 12, 31)
    givenTransactions(start, end)

    val points = service.getPaymentStatistics(MetricScope.MONTH, start, end, jwtUser)

    assertThat(points).hasSize(11 * 12)
  }

  private fun assertBadRequest(thrown: Throwable?) {
    assertThat(thrown).isInstanceOf(ResponseStatusException::class.java)
    assertThat((thrown as ResponseStatusException).statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
  }

  private fun totals(points: List<PaymentMetricResponse>) = points.map { it.total }

  private fun givenTransactions(
    start: LocalDate,
    end: LocalDate,
    vararg transactions: TransactionResponse,
  ) {
    Mockito.`when`(transactionSpi.getTransactionsByDateRange(start, end, jwtUser))
      .thenReturn(transactions.toList())
  }

  private fun transaction(date: LocalDate, amount: String, type: TransactionType) =
    TransactionResponse(UUID.randomUUID(), BigDecimal(amount), date, type, createdAt, null)
}
