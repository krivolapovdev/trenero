package org.trenero.backend.metric.internal.domain

import java.time.DayOfWeek
import java.time.LocalDate
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

/**
 * The bucketing of the metric module. A scope answers two questions: which period a day belongs to
 * (so that a chart has one point per period) and which period comes next (so that the periods
 * between two dates can be walked).
 */
class MetricScopeTest {

  @Test
  fun weekTruncatesToItsMonday() {
    // 2026-10-08 is a Thursday, so the week starts on 2026-10-05.
    assertThat(MetricScope.WEEK.truncate(LocalDate.of(2026, 10, 8)))
      .isEqualTo(LocalDate.of(2026, 10, 5))
  }

  @Test
  fun weekSticksToItsOwnMonday() {
    assertThat(MetricScope.WEEK.truncate(LocalDate.of(2026, 10, 5)))
      .isEqualTo(LocalDate.of(2026, 10, 5))
  }

  // A Sunday closes the week that started on the Monday before it, it does not open a new one.
  @Test
  fun weekKeepsSundayInTheWeekThatAlreadyStarted() {
    val sunday = LocalDate.of(2026, 10, 11)

    assertThat(sunday.dayOfWeek).isEqualTo(DayOfWeek.SUNDAY)
    assertThat(MetricScope.WEEK.truncate(sunday)).isEqualTo(LocalDate.of(2026, 10, 5))
  }

  @Test
  fun weekStepsAWholeWeek() {
    assertThat(MetricScope.WEEK.next(LocalDate.of(2026, 10, 5)))
      .isEqualTo(LocalDate.of(2026, 10, 12))
  }

  @Test
  fun monthTruncatesToTheFirstDay() {
    assertThat(MetricScope.MONTH.truncate(LocalDate.of(2026, 10, 31)))
      .isEqualTo(LocalDate.of(2026, 10, 1))
  }

  @Test
  fun monthRollsOverTheYear() {
    assertThat(MetricScope.MONTH.next(LocalDate.of(2026, 12, 1)))
      .isEqualTo(LocalDate.of(2027, 1, 1))
  }

  @Test
  fun yearTruncatesToTheFirstOfJanuary() {
    assertThat(MetricScope.YEAR.truncate(LocalDate.of(2026, 10, 8)))
      .isEqualTo(LocalDate.of(2026, 1, 1))
  }

  @Test
  fun yearHandlesALeapDay() {
    assertThat(MetricScope.YEAR.truncate(LocalDate.of(2028, 2, 29)))
      .isEqualTo(LocalDate.of(2028, 1, 1))
    assertThat(MetricScope.YEAR.next(LocalDate.of(2028, 1, 1))).isEqualTo(LocalDate.of(2029, 1, 1))
  }

  /** Walking a scope from a truncated date has to visit only truncated dates. */
  @Test
  fun steppedPeriodsStayAlignedToTheScope() {
    MetricScope.entries.forEach { scope ->
      val start = scope.truncate(LocalDate.of(2026, 10, 8))
      val next = scope.next(start)

      assertThat(scope.truncate(next)).isEqualTo(next)
    }
  }
}
