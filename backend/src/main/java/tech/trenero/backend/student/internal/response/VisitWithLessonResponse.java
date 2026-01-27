package tech.trenero.backend.student.internal.response;

import jakarta.validation.constraints.NotNull;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.VisitResponse;

public record VisitWithLessonResponse(
    @NotNull VisitResponse visit, @NotNull LessonResponse lesson) {}
