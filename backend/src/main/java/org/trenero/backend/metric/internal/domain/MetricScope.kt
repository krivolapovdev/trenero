package org.trenero.backend.metric.internal.domain

import java.time.DayOfWeek
import java.time.OffsetDateTime
import java.time.temporal.TemporalAdjuster
import java.time.temporal.TemporalAdjusters

/**
 * The bucketing of the metric module. A scope answers two questions: which period a value belongs
 * to (so that a chart has one point per period) and which period comes next (so that the periods
 * between two values can be walked). The start of a period keeps the offset of the value, so a
 * value that carries a region is bucketed by the days of that region.
 */
enum class MetricScope(
  val truncate: (OffsetDateTime) -> OffsetDateTime,
  val next: (OffsetDateTime) -> OffsetDateTime,
) {
  WEEK(
    truncate = { it.truncateTo(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)) },
    next = { it.plusWeeks(1) },
  ),
  MONTH(
    truncate = { it.truncateTo(TemporalAdjusters.firstDayOfMonth()) },
    next = { it.plusMonths(1) },
  ),
  YEAR(
    truncate = { it.truncateTo(TemporalAdjusters.firstDayOfYear()) },
    next = { it.plusYears(1) },
  ),
}

/** The first moment of the period that holds the value, in the offset the value carries. */
private fun OffsetDateTime.truncateTo(adjuster: TemporalAdjuster): OffsetDateTime =
  toLocalDate().with(adjuster).atStartOfDay().atOffset(offset)
