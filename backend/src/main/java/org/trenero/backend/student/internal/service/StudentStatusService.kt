package org.trenero.backend.student.internal.service

import java.time.LocalDate
import java.util.EnumSet
import org.springframework.stereotype.Service
import org.trenero.backend.common.domain.StudentStatus
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.lesson.external.response.LessonResponse
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse
import org.trenero.backend.transaction.external.response.TransactionResponse
import org.trenero.backend.visit.external.response.VisitResponse

@Service
class StudentStatusService {

  /** The badges of a student, the visit badge read from the last lesson of any kind. */
  fun getStudentStatuses(
    visits: List<VisitResponse>,
    payments: List<TransactionResponse>,
    lessons: List<LessonResponse> = emptyList(),
    free: Boolean = false,
  ): Set<StudentStatus> = getStudentStatuses(visits, payments, lessons, free, lessons)

  /**
   * The badges of a student, the visit badge read from [visitLessons] instead of [lessons].
   *
   * The student overview reads the visit badge from the last lesson of any kind, whether that
   * lesson belongs to a group or to the student alone. A group page passes the lessons of that
   * group, so "present" and "missing" tell whether the student came to the last lesson of the group
   * instead of the last lesson of any group the student belongs to. The payment badge stays read
   * from every payment and from the last lesson of any kind.
   */
  fun getStudentStatuses(
    visits: List<VisitResponse>,
    payments: List<TransactionResponse>,
    lessons: List<LessonResponse>,
    free: Boolean,
    visitLessons: List<LessonResponse>,
  ): Set<StudentStatus> {
    // A student without a mark carries no visit at all, so any visit means they were marked.
    val hasAnyVisit = visits.isNotEmpty()

    if (!hasAnyVisit && payments.isEmpty()) {
      return setOf(if (free) StudentStatus.FREE else StudentStatus.INACTIVE)
    }

    val statuses = EnumSet.noneOf(StudentStatus::class.java)

    // The visit badge comes from the last lesson the student is marked for. Several lessons can
    // share a day, so of the lessons of the last day the one created last counts as the last
    // lesson.
    val lastVisitLesson =
      visitLessons.maxWithOrNull(compareBy<LessonResponse> { it.date }.thenBy { it.createdAt })

    if (lastVisitLesson != null) {
      visits
        .firstOrNull { it.lessonId == lastVisitLesson.id }
        ?.status
        ?.let { status ->
          statuses.add(
            if (status == VisitStatus.PRESENT) StudentStatus.PRESENT else StudentStatus.MISSING
          )
        }
    }

    // A student who studies for free is never charged, so the payment badge is FREE and the
    // subscription dates of any past payments are irrelevant.
    if (free) {
      statuses.add(StudentStatus.FREE)

      return statuses
    }

    val lastLesson =
      lessons.maxWithOrNull(compareBy<LessonResponse> { it.date }.thenBy { it.createdAt })

    val referenceDate = lastLesson?.date ?: LocalDate.now()

    val maxPaidUntil =
      payments
        .mapNotNull { (it.paymentDetails as? StudentPaymentDetailsResponse)?.paidUntil }
        .maxOrNull()

    val isSubscriptionActive = maxPaidUntil?.let { !it.isBefore(referenceDate) } ?: false

    statuses.add(if (isSubscriptionActive) StudentStatus.PAID else StudentStatus.UNPAID)

    return statuses
  }
}
