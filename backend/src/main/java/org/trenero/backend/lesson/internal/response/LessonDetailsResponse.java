package org.trenero.backend.lesson.internal.response;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.visit.external.response.VisitResponse;

/**
 * The lesson together with the attendance that is recorded for it.
 *
 * <p>The students the visits belong to are carried next to the visits, because leaving a group
 * drops the student link: a student that came to the lesson has to keep showing up in it after they
 * left the group.
 */
public record LessonDetailsResponse(
    @NotNull @JsonUnwrapped LessonResponse lesson,
    @NotNull List<VisitResponse> studentVisits,
    @NotNull List<StudentResponse> students) {}
