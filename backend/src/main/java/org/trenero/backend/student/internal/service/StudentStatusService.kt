package org.trenero.backend.student.internal.service

import java.time.LocalDate
import java.util.EnumSet
import org.springframework.stereotype.Service
import org.trenero.backend.common.domain.StudentStatus
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType
import org.trenero.backend.lesson.external.response.LessonResponse
import org.trenero.backend.transaction.external.response.StudentPaymentDetailsResponse
import org.trenero.backend.transaction.external.response.TransactionResponse
import org.trenero.backend.visit.external.response.VisitResponse

@Service
class StudentStatusService {

  fun getStudentStatuses(
    visits: List<VisitResponse>,
    payments: List<TransactionResponse>,
    lastLesson: LessonResponse? = null,
  ): Set<StudentStatus> {
    val hasAnyMarkedVisit = visits.any { it.status != VisitStatus.UNMARKED }

    if (!hasAnyMarkedVisit && payments.isEmpty()) {
      return setOf(StudentStatus.INACTIVE)
    }

    val statuses = EnumSet.noneOf(StudentStatus::class.java)

    if (lastLesson != null) {
      visits
        .firstOrNull { it.type != VisitType.UNMARKED && it.lessonId == lastLesson.id }
        ?.status
        ?.let { status ->
          statuses.add(
            if (status == VisitStatus.PRESENT) StudentStatus.PRESENT else StudentStatus.MISSING
          )
        }
    }

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
