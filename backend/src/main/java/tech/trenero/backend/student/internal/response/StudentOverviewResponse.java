package tech.trenero.backend.student.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.Set;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.internal.domain.StudentStatus;

public record StudentOverviewResponse(
    @JsonUnwrapped StudentResponse student,
    GroupResponse studentGroup,
    @NotNull Set<StudentStatus> statuses) {}
