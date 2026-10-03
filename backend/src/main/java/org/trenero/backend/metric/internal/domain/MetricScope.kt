package org.trenero.backend.metric.internal.domain

import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters

enum class MetricScope(
  val truncate: (LocalDate) -> LocalDate,
  val next: (LocalDate) -> LocalDate,
) {
  WEEK(
    truncate = { it.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)) },
    next = { it.plusWeeks(1) },
  ),
  MONTH(
    truncate = { it.with(TemporalAdjusters.firstDayOfMonth()) },
    next = { it.plusMonths(1) },
  ),
  YEAR(
    truncate = { it.with(TemporalAdjusters.firstDayOfYear()) },
    next = { it.plusYears(1) },
  ),
}
