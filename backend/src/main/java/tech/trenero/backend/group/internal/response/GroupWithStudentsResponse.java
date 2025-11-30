package tech.trenero.backend.group.internal.response;

import java.util.List;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;

public record GroupWithStudentsResponse(
    GroupResponse groupResponse, List<StudentResponse> students) {}
