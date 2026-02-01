package tech.trenero.backend.student.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Set;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.internal.domain.StudentStatus;

public record StudentDetailsResponse(
    @JsonUnwrapped StudentResponse student,
    GroupResponse studentGroup,
    @NotNull List<VisitWithLessonResponse> studentVisits,
    @NotNull List<StudentPaymentResponse> studentPayments,
    @NotNull Set<StudentStatus> statuses) {}
