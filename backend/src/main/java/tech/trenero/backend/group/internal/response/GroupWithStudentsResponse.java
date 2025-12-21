package tech.trenero.backend.group.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import java.util.List;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;

public record GroupWithStudentsResponse(
    @JsonUnwrapped GroupResponse groupResponse, List<StudentResponse> students) {}
