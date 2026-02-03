package org.trenero.backend.group.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import org.trenero.backend.common.response.GroupResponse;
import org.trenero.backend.common.response.StudentResponse;

public record GroupOverviewResponse(
    @NotNull @JsonUnwrapped GroupResponse group, @NotNull List<StudentResponse> groupStudents) {}
