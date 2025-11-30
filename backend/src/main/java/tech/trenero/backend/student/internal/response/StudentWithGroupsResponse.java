package tech.trenero.backend.student.internal.response;

import java.util.List;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;

public record StudentWithGroupsResponse(
    StudentResponse studentResponse, List<GroupResponse> studentGroups) {}
