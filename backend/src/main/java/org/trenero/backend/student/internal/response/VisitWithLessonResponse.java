package org.trenero.backend.student.internal.response;

import jakarta.validation.constraints.NotNull;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.visit.external.response.VisitResponse;

public record VisitWithLessonResponse(
    @NotNull VisitResponse visit, @NotNull LessonResponse lesson) {}
