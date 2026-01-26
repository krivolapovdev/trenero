package tech.trenero.backend.group.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;

public record GroupUpdateDetailsResponse(
    @NotNull @JsonUnwrapped GroupResponse group,
    @NotNull List<StudentResponse> groupStudents,
    @NotNull List<StudentResponse> allStudents) {}
