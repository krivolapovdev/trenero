package tech.trenero.backend.student.internal.service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.student.internal.domain.StudentStatus;

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

    if (visits.isEmpty() && payments.isEmpty()) {
      return Set.of(StudentStatus.INACTIVE);
    }

    Set<StudentStatus> statuses = new HashSet<>();

    if (lastLesson != null) {
      visits.stream()
          .filter(v -> v.lessonId().equals(lastLesson.id()))
          .findFirst()
          .ifPresent(
              lastVisit ->
                  statuses.add(
                      lastVisit.present() ? StudentStatus.PRESENT : StudentStatus.MISSING));
    }

    int totalPaidLessons = payments.stream().mapToInt(StudentPaymentResponse::paidLessons).sum();
    int totalVisits = visits.size();

    statuses.add(totalVisits <= totalPaidLessons ? StudentStatus.PAID : StudentStatus.UNPAID);

    return statuses;
  }
}
