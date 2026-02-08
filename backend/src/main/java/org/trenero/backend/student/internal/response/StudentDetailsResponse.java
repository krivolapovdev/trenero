package org.trenero.backend.student.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Set;
import org.trenero.backend.common.response.GroupResponse;
import org.trenero.backend.common.response.StudentPaymentResponse;
import org.trenero.backend.common.response.StudentResponse;
import org.trenero.backend.student.internal.domain.StudentStatus;

public record StudentDetailsResponse(
    @JsonUnwrapped StudentResponse student,
    GroupResponse studentGroup,
    @NotNull List<StudentGroupHistoryResponse> groupsHistory,
    @NotNull List<StudentPaymentResponse> studentPayments,
    @NotNull Set<StudentStatus> statuses) {}
