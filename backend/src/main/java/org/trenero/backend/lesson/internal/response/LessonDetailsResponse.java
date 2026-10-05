package org.trenero.backend.lesson.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.visit.external.response.VisitResponse;

public record LessonDetailsResponse(
    @NotNull @JsonUnwrapped LessonResponse lesson, @NotNull List<VisitResponse> studentVisits) {}
