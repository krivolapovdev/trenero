package tech.trenero.backend.student.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import java.util.List;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;

public record StudentWithGroupsResponse(
    @JsonUnwrapped StudentResponse studentResponse, List<GroupResponse> studentGroups) {}
