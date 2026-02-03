package org.trenero.backend.student.internal.response;

import jakarta.validation.constraints.NotNull;
import org.trenero.backend.common.response.LessonResponse;
import org.trenero.backend.common.response.VisitResponse;

public record VisitWithLessonResponse(
    @NotNull VisitResponse visit, @NotNull LessonResponse lesson) {}
