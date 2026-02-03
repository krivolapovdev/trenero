package org.trenero.backend.student.internal.service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.trenero.backend.common.domain.VisitStatus;
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
    log.info("Getting students statuses");

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
          .filter(v -> v.lessonId().equals(lastLesson.id()))
          .findFirst()
          .ifPresent(
              lastVisit -> {
                VisitStatus status = lastVisit.status();
                if (status == VisitStatus.PRESENT || status == VisitStatus.FREE) {
                  statuses.add(StudentStatus.PRESENT);
                } else if (status == VisitStatus.ABSENT) {
                  statuses.add(StudentStatus.MISSING);
                }
              });
    }

    long billableVisits =
        visits.stream()
            .filter(v -> v.status() == VisitStatus.PRESENT || v.status() == VisitStatus.ABSENT)
            .count();

    int totalPaidLessons = payments.stream().mapToInt(StudentPaymentResponse::paidLessons).sum();

    statuses.add(billableVisits <= totalPaidLessons ? StudentStatus.PAID : StudentStatus.UNPAID);

    return statuses;
  }
}
