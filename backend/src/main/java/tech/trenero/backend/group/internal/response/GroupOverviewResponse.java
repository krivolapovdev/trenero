package tech.trenero.backend.group.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import tech.trenero.backend.common.response.GroupResponse;

public record GroupOverviewResponse(
    @NotNull @JsonUnwrapped GroupResponse group, @NotNull Integer studentsCount) {}
