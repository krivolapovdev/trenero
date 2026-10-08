package org.trenero.backend.group.internal.service

import java.time.LocalDate
import java.time.YearMonth
import java.util.UUID
import org.springframework.stereotype.Service
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.group.external.response.GroupResponse
import org.trenero.backend.group.internal.response.GroupReportResponse
import org.trenero.backend.group.internal.response.GroupReportStudentResponse
import org.trenero.backend.lesson.external.response.LessonResponse
import org.trenero.backend.student.external.response.StudentResponse
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse
import org.trenero.backend.transaction.external.response.TransactionResponse
import org.trenero.backend.visit.external.response.VisitResponse

/**
 * Builds the monthly group report out of already loaded students, lessons, visits and payments.
 *
 * The class keeps no persistence logic so the report rules (day marks, per student result and the
 * paid flag) can be verified in isolation.
 */
@Service
class GroupReportService {

  fun buildReport(
    group: GroupResponse,
    year: Int,
    month: Int,
    students: List<StudentResponse>,
    lessons: List<LessonResponse>,
    visitsByStudentId: Map<UUID, List<VisitResponse>>,
    paymentsByStudentId: Map<UUID, List<TransactionResponse>>,
    today: LocalDate,
  ): GroupReportResponse {
    val period = YearMonth.of(year, month)
    val dayCount = period.lengthOfMonth()

    val lessonIdsByDate =
      lessons.filter { YearMonth.from(it.date) == period }.groupBy({ it.date }, { it.id })
    val lessonDays = lessonIdsByDate.keys.map { it.dayOfMonth }.sorted()
    val statusesByStudentId = visitsByStudentId.mapValues { (_, visits) ->
      visits.groupBy({ it.lessonId }, { it.status })
    }

    val rows =
      students
        .sortedBy { it.fullName.lowercase() }
        .map { student ->
          val statusesByLessonId = statusesByStudentId.getOrDefault(student.id, emptyMap())

          val presentDays = lessonDays.filter { day ->
            lessonIdsByDate.getValue(period.atDay(day)).any { lessonId ->
              statusesByLessonId[lessonId]?.contains(VisitStatus.PRESENT) == true
            }
          }

          GroupReportStudentResponse(
            studentId = student.id,
            fullName = student.fullName,
            paid = isPaid(paymentsByStudentId.getOrDefault(student.id, emptyList()), period, today),
            presentDays = presentDays,
            presentCount = presentDays.size,
            lessonCount = lessonDays.size,
          )
        }

    return GroupReportResponse(
      groupId = group.id,
      groupName = group.name,
      year = year,
      month = month,
      dayCount = dayCount,
      lessonDays = lessonDays,
      students = rows,
      totalPresent = rows.sumOf { it.presentCount },
      totalLessons = rows.sumOf { it.lessonCount },
    )
  }

  /**
   * A student is treated as paid for the period when the latest `paidUntil` date reaches the
   * reference date of that period: the last day of a month that is already over, today inside the
   * current month and the first day of a month that has not started yet.
   */
  private fun isPaid(
    payments: List<TransactionResponse>,
    period: YearMonth,
    today: LocalDate,
  ): Boolean {
    val maxPaidUntil =
      payments
        .mapNotNull { (it.paymentDetails as? StudentPaymentDetailsResponse)?.paidUntil }
        .maxOrNull() ?: return false

    val referenceDate =
      when {
        period.atDay(1).isAfter(today) -> period.atDay(1)
        period.atEndOfMonth().isBefore(today) -> period.atEndOfMonth()
        else -> today
      }

    return !maxPaidUntil.isBefore(referenceDate)
  }
}
