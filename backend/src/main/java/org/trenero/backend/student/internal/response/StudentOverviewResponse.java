package org.trenero.backend.student.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.Set;
import org.trenero.backend.common.response.GroupResponse;
import org.trenero.backend.common.response.StudentResponse;
import org.trenero.backend.student.internal.domain.StudentStatus;

public record StudentOverviewResponse(
    @JsonUnwrapped StudentResponse student,
    GroupResponse studentGroup,
    @NotNull Set<StudentStatus> statuses) {}
