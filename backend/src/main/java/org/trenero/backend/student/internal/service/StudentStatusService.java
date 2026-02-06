package org.trenero.backend.student.internal.service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.trenero.backend.common.domain.VisitStatus;
import org.trenero.backend.common.domain.VisitType;
import org.trenero.backend.common.response.LessonResponse;
import org.trenero.backend.common.response.StudentPaymentResponse;
import org.trenero.backend.common.response.VisitResponse;
import org.trenero.backend.student.internal.domain.StudentStatus;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentStatusService {
  public Set<StudentStatus> getStudentStatuses(
      List<VisitResponse> visits,
      List<StudentPaymentResponse> payments,
      LessonResponse lastLesson) {
    log.info(
        "Getting student statuses: visits={}; payments={}; lastLesson={}",
        visits,
        payments,
        lastLesson);

    visits = visits == null ? List.of() : visits;
    payments = payments == null ? List.of() : payments;

    boolean allVisitsUnmarked =
        visits.stream().allMatch(visit -> visit.status().equals(VisitStatus.UNMARKED));

    if ((visits.isEmpty() || allVisitsUnmarked) && payments.isEmpty()) {
      return Set.of(StudentStatus.INACTIVE);
    }

    Set<StudentStatus> statuses = new HashSet<>();

    if (lastLesson != null) {
      visits.stream()
          .filter(v -> v.type() != VisitType.UNMARKED)
          .filter(v -> v.lessonId().equals(lastLesson.id()))
          .findFirst()
          .map(VisitResponse::status)
          .ifPresent(
              status ->
                  statuses.add(
                      status.equals(VisitStatus.PRESENT)
                          ? StudentStatus.PRESENT
                          : StudentStatus.MISSING));
    }

    LocalDate referenceDate =
        (lastLesson != null) ? lastLesson.startDateTime().toLocalDate() : LocalDate.now();

    boolean isSubscriptionActive =
        payments.stream()
            .max(Comparator.comparing(StudentPaymentResponse::paidUntil))
            .map(payment -> !payment.paidUntil().isBefore(referenceDate))
            .orElse(false);

    statuses.add(isSubscriptionActive ? StudentStatus.PAID : StudentStatus.UNPAID);

    return statuses;
  }
}
