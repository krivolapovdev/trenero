package tech.trenero.backend.lesson.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import tech.trenero.backend.common.response.GroupStudentResponse;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.VisitResponse;

public record LessonDetailsResponse(
    @NotNull @JsonUnwrapped LessonResponse lesson,
    @NotNull List<VisitResponse> studentVisits,
    @NotNull List<GroupStudentResponse> groupStudents) {}
