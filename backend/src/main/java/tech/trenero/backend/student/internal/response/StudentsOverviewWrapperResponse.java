package tech.trenero.backend.student.internal.response;

import jakarta.validation.constraints.NotNull;
import java.util.List;
import tech.trenero.backend.common.response.GroupResponse;

public record StudentsOverviewWrapperResponse(
    @NotNull List<StudentOverviewResponse> students, @NotNull List<GroupResponse> allGroups) {}
