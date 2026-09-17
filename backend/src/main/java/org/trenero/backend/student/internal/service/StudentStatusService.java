package org.trenero.backend.student.internal.service;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.NonNull;
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

  public @NonNull Set<StudentStatus> getStudentStatuses(
      @NonNull List<VisitResponse> visits,
      @NonNull List<StudentPaymentResponse> payments,
      LessonResponse lastLesson) {
    boolean hasAnyMarkedVisit =
        visits.stream().anyMatch(visit -> visit.status() != VisitStatus.UNMARKED);

    if (!hasAnyMarkedVisit && payments.isEmpty()) {
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

    var referenceDate = (lastLesson != null) ? lastLesson.date() : LocalDate.now();

    boolean isSubscriptionActive =
        payments.stream()
            .max(Comparator.comparing(StudentPaymentResponse::paidUntil))
            .map(payment -> !payment.paidUntil().isBefore(referenceDate))
            .orElse(false);

    statuses.add(isSubscriptionActive ? StudentStatus.PAID : StudentStatus.UNPAID);

    return statuses;
  }
}
